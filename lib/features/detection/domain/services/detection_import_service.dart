import 'package:dompet/core/enums.dart';
import 'package:dompet/core/error/result.dart';
import 'package:dompet/core/utils/logger.dart';
import 'package:dompet/features/accounts/domain/account_model.dart';
import 'package:dompet/features/accounts/domain/i_account_repository.dart';
import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/features/categories/domain/i_category_repository.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:dompet/features/detection/domain/i_detection_repository.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:dompet/features/detection/domain/parsers/notification_text_utils.dart';
import 'package:dompet/features/detection/domain/parsers/parser_registry.dart';
import 'package:dompet/features/detection/domain/services/category_inference_engine.dart';
import 'package:dompet/features/detection/domain/services/detection_policy.dart';
import 'package:dompet/features/detection/domain/services/import_outcome.dart';
import 'package:dompet/features/detection/domain/services/salary_detector.dart';
import 'package:dompet/features/detection/domain/transaction_candidate.dart';
import 'package:dompet/features/transactions/domain/i_transaction_repository.dart';
import 'package:dompet/features/transactions/domain/transaction_model.dart';
import 'package:uuid/uuid.dart';

/// Orchestrates the local notification-to-ledger import pipeline.
class DetectionImportService {
  /// Creates the import pipeline with its collaborators.
  DetectionImportService(
    this._detectionRepository,
    this._transactionRepository,
    this._accountRepository,
    this._categoryRepository, {
    NotificationParserRegistry? registry,
    SalaryDetector? salaryDetector,
    CategoryInferenceEngine? categoryEngine,
  })  : _registry = registry ?? const NotificationParserRegistry(),
        _salaryDetector = salaryDetector ?? const SalaryDetector(),
        _categoryEngine = categoryEngine ?? CategoryInferenceEngine();

  final IDetectionRepository _detectionRepository;
  final ITransactionRepository _transactionRepository;
  final IAccountRepository _accountRepository;
  final ICategoryRepository _categoryRepository;
  final NotificationParserRegistry _registry;
  final SalaryDetector _salaryDetector;
  final CategoryInferenceEngine _categoryEngine;

  /// Cheap filter run before parsing: irrelevant notifications are skipped.
  bool isRelevant(NotificationPayload payload) {
    final text = '${payload.title} ${payload.body}';
    if (text.trim().length < 12) return false;
    const ignoredPackages = {
      'android', 'com.android.systemui', 'com.google.android.gms', 'com.android.vending',
      'com.google.android.apps.messaging', 'org.telegram.messenger', 'com.whatsapp',
    };
    if (ignoredPackages.contains(payload.package)) return false;
    return true;
  }

  /// Runs the full pipeline for one notification.
  Future<ImportOutcome> handle(NotificationPayload payload) async {
    final policy = await _loadPolicy();
    if (!policy.enabled || !isRelevant(payload)) {
      return const ImportOutcome(type: ImportOutcomeType.discarded);
    }

    final candidate = _registry.parse(payload);
    if (candidate == null) {
      return const ImportOutcome(type: ImportOutcomeType.discarded);
    }

    final fingerprint = candidate.fingerprint;
    if (await _detectionRepository.hasFingerprint(fingerprint)) {
      return const ImportOutcome(type: ImportOutcomeType.duplicate);
    }
    final since = DateTime.now().toUtc().subtract(const Duration(hours: 48));
    if (await _detectionRepository.hasRecentSimilar(
      sourcePackage: candidate.sourcePackage,
      amount: candidate.amount,
      type: candidate.type,
      merchant: candidate.merchant,
      counterparty: candidate.counterparty,
      since: since,
    )) {
      return const ImportOutcome(type: ImportOutcomeType.duplicate);
    }

    final salaryAssessment = await _assessSalary(candidate);
    final categoryResolution = await _resolveCategory(candidate);
    final now = DateTime.now().toUtc();

    final detectionId = _uuid.v7();
    final model = TransactionDetectionModel(
      id: detectionId,
      fingerprint: fingerprint,
      sourcePackage: candidate.sourcePackage,
      type: candidate.type,
      amount: candidate.amount,
      confidence: candidate.confidence,
      confidenceTier: candidate.confidenceTier,
      method: candidate.method,
      parserVersion: candidate.parserVersion,
      status: DetectionStatus.pending,
      occurredAt: candidate.occurredAt,
      createdAt: now,
      merchant: candidate.merchant,
      counterparty: candidate.counterparty,
      referenceId: candidate.referenceId,
      categoryId: categoryResolution?.categoryId,
    );

    if (policy.shouldAutoImport(candidate.confidence)) {
      final account = await _pickDefaultAccount();
      if (account != null) {
        final imported = await _autoImport(
          candidate: candidate,
          accountId: account.id,
          categoryId: categoryResolution?.categoryId,
          salaryScore: salaryAssessment.score,
        );
        if (imported) {
          await _detectionRepository.saveCandidate(model.copyWith(status: DetectionStatus.imported, accountId: account.id));
          if (candidate.type == DetectionTransactionType.income && salaryAssessment.isHighConfidence) {
            await _detectionRepository.recordSalary(
              amount: candidate.amount,
              dayOfMonth: candidate.occurredAt.day,
              confidence: salaryAssessment.score,
            );
          }
          return ImportOutcome(
            type: ImportOutcomeType.imported,
            detectionId: detectionId,
            amount: candidate.amount,
            confidence: candidate.confidence,
            isSalary: candidate.type == DetectionTransactionType.income && salaryAssessment.isHighConfidence,
          );
        }
      }
    }

    if (policy.shouldReview(candidate.confidence)) {
      await _detectionRepository.saveCandidate(model);
      return ImportOutcome(
        type: ImportOutcomeType.review,
        detectionId: detectionId,
        amount: candidate.amount,
        confidence: candidate.confidence,
        isSalary: candidate.type == DetectionTransactionType.income && salaryAssessment.score >= 0.7,
      );
    }

    return ImportOutcome(
      type: ImportOutcomeType.discarded,
      amount: candidate.amount,
      confidence: candidate.confidence,
    );
  }

  Future<bool> _autoImport({
    required TransactionCandidate candidate,
    required String accountId,
    required String? categoryId,
    required double salaryScore,
  }) async {
    final now = DateTime.now().toUtc();
    final party = candidate.merchant ?? candidate.counterparty;
    final note = [
      if (party != null && party.isNotEmpty) party,
      if (candidate.referenceId != null) 'Ref: ${candidate.referenceId}',
    ].join(' · ');
    final transactionId = _uuid.v7();
    final transaction = TransactionModel(
      id: transactionId,
      accountId: accountId,
      type: _toLedgerType(candidate.type),
      amount: candidate.amount,
      transactionDate: candidate.occurredAt,
      createdAt: now,
      updatedAt: now,
      note: note.isEmpty ? null : note,
      items: [
        TransactionItemModel(
          id: _uuid.v7(),
          transactionId: transactionId,
          amount: candidate.amount,
          categoryId: categoryId,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );
    final result = await _transactionRepository.createTransaction(transaction);
    switch (result) {
      case Success(value: _):
        return true;
      case ErrorResult(:final error):
        talker.error('Auto-import failed', error);
        return false;
    }
  }

  Future<({String? categoryId, double confidence})?> _resolveCategory(TransactionCandidate candidate) async {
    final party = (candidate.merchant ?? candidate.counterparty)?.trim();
    if (party == null || party.isEmpty) return null;

    final learned = await _detectionRepository.getLearnedCategory(party);
    if (learned != null && await _categoryExists(learned)) {
      return (categoryId: learned, confidence: 0.97);
    }

    final inference = _categoryEngine.infer(party);
    if (inference != null) {
      final match = await _findCategoryByName(inference.label);
      if (match != null) {
        return (categoryId: match.id, confidence: inference.confidence);
      }
    }
    return null;
  }

  Future<bool> _categoryExists(String categoryId) async {
    final result = await _categoryRepository.getCategoryById(categoryId);
    return switch (result) {
      Success(value: _) => true,
      ErrorResult(error: _) => false,
    };
  }

  Future<CategoryModel?> _findCategoryByName(String label) async {
    final result = await _categoryRepository.getCategories();
    final categories = switch (result) {
      Success(value: final data) => data,
      ErrorResult(error: _) => <CategoryModel>[],
    };
    final normalized = normalizeText(label);
    for (final category in categories) {
      if (category.type == CategoryType.expense && normalizeText(category.name) == normalized) {
        return category;
      }
    }
    return null;
  }

  Future<SalaryAssessment> _assessSalary(TransactionCandidate candidate) async {
    if (candidate.type != DetectionTransactionType.income) {
      return const SalaryAssessment(score: 0, reason: 'not_income');
    }
    final history = await _salaryHistory();
    return _salaryDetector.assess(
      sourceText: candidate.sourceText,
      amount: candidate.amount,
      occurredAt: candidate.occurredAt,
      history: history,
    );
  }

  Future<List<SalaryObservation>> _salaryHistory() async {
    final since = DateTime.now().toUtc().subtract(const Duration(days: 95));
    final result = await _transactionRepository
        .watchTransactions(startDate: since, endDate: DateTime.now().toUtc(), types: {TransactionType.income})
        .first;
    return switch (result) {
      Success(value: final transactions) => transactions
          .map((t) => SalaryObservation(amount: t.amount, occurredAt: t.transactionDate))
          .toList(),
      ErrorResult(error: _) => <SalaryObservation>[],
    };
  }

  Future<AccountModel?> _pickDefaultAccount() async {
    final result = await _accountRepository.getAccounts();
    final accounts = switch (result) {
      Success(value: final data) => data,
      ErrorResult(error: _) => <AccountModel>[],
    };
    final main = accounts.where((a) => a.isActive && a.type == AccountType.assets && !a.isPocket).toList()..sort((a, b) => a.sort.compareTo(b.sort));
    if (main.isNotEmpty) return main.first;
    final any = accounts.where((a) => a.isActive && a.type == AccountType.assets).toList()..sort((a, b) => a.sort.compareTo(b.sort));
    return any.isEmpty ? null : any.first;
  }

  Future<DetectionPolicy> _loadPolicy() async {
    final map = <String, String?>{
      'detectionEnabled': await _detectionRepository.getSetting('detectionEnabled'),
      'detectionAutoImportEnabled': await _detectionRepository.getSetting('detectionAutoImportEnabled'),
      'detectionAutoImportThreshold': await _detectionRepository.getSetting('detectionAutoImportThreshold'),
      'salaryDetectionEnabled': await _detectionRepository.getSetting('salaryDetectionEnabled'),
    };
    return DetectionPolicy.fromSettings(map);
  }

  static TransactionType _toLedgerType(DetectionTransactionType type) {
    return switch (type) {
      DetectionTransactionType.income => TransactionType.income,
      DetectionTransactionType.expense => TransactionType.expense,
      DetectionTransactionType.transfer => TransactionType.transfer,
    };
  }

  final _uuid = const Uuid();
}
