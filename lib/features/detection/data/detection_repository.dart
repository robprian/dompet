import 'package:dompet/database/daos/detection_dao.dart';
import 'package:dompet/database/database.dart' as db;
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:dompet/features/detection/domain/i_detection_repository.dart';
import 'package:drift/drift.dart';

/// Drift-backed repository for locally detected transaction candidates.
class DetectionRepository implements IDetectionRepository {
  /// Creates a repository backed by [dao].
  DetectionRepository(this.dao, this.database);

  /// Detection-specific DAO.
  final DetectionDao dao;

  /// Main database for settings and similarity queries.
  final db.AppDatabase database;

  @override
  Stream<List<TransactionDetectionModel>> watchPending() {
    return dao.watchPending().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<int> countPending() async {
    final rows = await dao.watchPending().first;
    return rows.length;
  }

  @override
  Future<void> saveCandidate(TransactionDetectionModel model) async {
    await dao.insertDetection(
      db.TransactionDetectionsCompanion.insert(
        id: Value(model.id),
        sourcePackage: model.sourcePackage,
        type: model.type,
        amount: model.amount,
        merchant: Value(model.merchant),
        counterparty: Value(model.counterparty),
        referenceId: Value(model.referenceId),
        accountId: Value(model.accountId),
        categoryId: Value(model.categoryId),
        confidence: model.confidence,
        confidenceTier: model.confidenceTier,
        method: model.method,
        parserVersion: model.parserVersion,
        status: Value(model.status),
        fingerprint: model.fingerprint,
        occurredAt: model.occurredAt.toUtc(),
        createdAt: Value(model.createdAt.toUtc()),
      ),
    );
  }

  @override
  Future<bool> hasFingerprint(String fingerprint) => dao.hasFingerprint(fingerprint);

  @override
  Future<bool> hasRecentSimilar({
    required String sourcePackage,
    required int amount,
    required DetectionTransactionType type,
    required String? merchant,
    required String? counterparty,
    required DateTime since,
  }) async {
    final query = database.select(database.transactionDetections)
      ..where(
        (t) =>
            t.sourcePackage.equals(sourcePackage) &
            t.amount.equals(amount) &
            t.type.equals(type.name) &
            t.occurredAt.isBiggerOrEqualValue(since.toUtc()),
      );
    final rows = await query.get();
    final party = (merchant ?? counterparty)?.trim().toLowerCase();
    if (party == null || party.isEmpty) return rows.isNotEmpty;
    return rows.any((row) => (row.merchant ?? row.counterparty)?.trim().toLowerCase() == party);
  }

  @override
  Future<void> resolveCandidate({
    required String id,
    required DetectionStatus status,
    String? accountId,
    String? categoryId,
  }) async {
    await dao.updateDetection(id: id, status: status, accountId: accountId, categoryId: categoryId);
  }

  @override
  Future<void> learnMerchantCategory({required String merchant, required String categoryId}) {
    return dao.learnMerchantCategory(merchant: merchant, categoryId: categoryId);
  }

  @override
  Future<String?> getLearnedCategory(String merchant) => dao.getLearnedCategory(merchant);

  @override
  Future<void> recordSalary({required int amount, required int dayOfMonth, required double confidence}) async {
    final existing = await (database.select(
      database.salaryProfiles,
    )..where((t) => t.amount.equals(amount) & t.dayOfMonth.equals(dayOfMonth))).getSingleOrNull();
    final now = DateTime.now().toUtc();
    if (existing == null) {
      await database
          .into(database.salaryProfiles)
          .insert(
            db.SalaryProfilesCompanion.insert(
              amount: Value(amount),
              dayOfMonth: Value(dayOfMonth),
              averageConfidence: Value(confidence),
              occurrenceCount: const Value(1),
              lastDetectedAt: Value(now),
            ),
          );
      return;
    }
    final count = existing.occurrenceCount + 1;
    final average = ((existing.averageConfidence * existing.occurrenceCount) + confidence) / count;
    await (database.update(database.salaryProfiles)..where((t) => t.id.equals(existing.id))).write(
      db.SalaryProfilesCompanion(
        averageConfidence: Value(average),
        occurrenceCount: Value(count),
        lastDetectedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<bool> hasSalaryRecord() async {
    final row = await (database.select(database.salaryProfiles)..limit(1)).getSingleOrNull();
    return row != null;
  }

  @override
  Future<String?> getSetting(String key) async {
    final row = await (database.select(database.settings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> setSetting(String key, String value) async {
    await database
        .into(database.settings)
        .insertOnConflictUpdate(
          db.SettingsCompanion.insert(key: key, value: value),
        );
  }

  TransactionDetectionModel _toDomain(db.TransactionDetection row) {
    return TransactionDetectionModel(
      id: row.id,
      fingerprint: row.fingerprint,
      sourcePackage: row.sourcePackage,
      type: row.type,
      amount: row.amount,
      confidence: row.confidence,
      confidenceTier: row.confidenceTier,
      method: row.method,
      parserVersion: row.parserVersion,
      status: row.status,
      occurredAt: row.occurredAt,
      createdAt: row.createdAt,
      merchant: row.merchant,
      counterparty: row.counterparty,
      referenceId: row.referenceId,
      categoryId: row.categoryId,
      accountId: row.accountId,
    );
  }
}
