import 'package:dompet/database/database.dart';
import 'package:dompet/database/tables/detection_table.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:drift/drift.dart';

part 'detection_dao.g.dart';

/// Data access object for local notification-derived transaction candidates.
@DriftAccessor(tables: [TransactionDetections, MerchantCategoryRules, SalaryProfiles])
class DetectionDao extends DatabaseAccessor<AppDatabase> with _$DetectionDaoMixin {
  /// Creates a detection DAO bound to [attachedDatabase].
  DetectionDao(super.attachedDatabase);

  /// Watches reviewable candidates ordered from newest to oldest.
  Stream<List<TransactionDetection>> watchPending() {
    return (select(transactionDetections)
          ..where((t) => t.status.equals(DetectionStatus.pending.name))
          ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
        .watch();
  }

  /// Gets one candidate by its ID.
  Future<TransactionDetection?> getById(String id) {
    return (select(transactionDetections)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Returns true when the normalized fingerprint has already been seen.
  Future<bool> hasFingerprint(String fingerprint) async {
    final row = await (select(
      transactionDetections,
    )..where((t) => t.fingerprint.equals(fingerprint))).getSingleOrNull();
    return row != null;
  }

  /// Stores a candidate after duplicate checking is performed by the caller.
  Future<int> insertDetection(TransactionDetectionsCompanion companion) =>
      into(transactionDetections).insert(companion);

  /// Updates the review state and optional account/category choices.
  Future<int> updateDetection({
    required String id,
    required DetectionStatus status,
    String? accountId,
    String? categoryId,
  }) {
    return (update(transactionDetections)..where((t) => t.id.equals(id))).write(
      TransactionDetectionsCompanion(
        status: Value(status),
        accountId: Value(accountId),
        categoryId: Value(categoryId),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Learns a merchant-category mapping from a reviewed candidate.
  Future<void> learnMerchantCategory({required String merchant, required String categoryId}) async {
    final normalized = merchant.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final existing = await (select(
      merchantCategoryRules,
    )..where((t) => t.merchantNormalized.equals(normalized))).getSingleOrNull();
    if (existing == null) {
      await into(merchantCategoryRules).insert(
        MerchantCategoryRulesCompanion.insert(
          merchantNormalized: normalized,
          categoryId: categoryId,
          hitCount: const Value(1),
        ),
      );
      return;
    }
    await (update(merchantCategoryRules)..where((t) => t.id.equals(existing.id))).write(
      MerchantCategoryRulesCompanion(
        categoryId: Value(categoryId),
        hitCount: Value(existing.hitCount + 1),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Resolves a learned merchant category, if one exists.
  Future<String?> getLearnedCategory(String merchant) async {
    final row = await (select(
      merchantCategoryRules,
    )..where((t) => t.merchantNormalized.equals(merchant.trim().toLowerCase()))).getSingleOrNull();
    return row?.categoryId;
  }
}
