// coverage:ignore-file
import 'package:dompet/database/tables/accounts_table.dart';
import 'package:dompet/database/tables/categories_table.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Detected transaction candidate produced by the local notification pipeline.
class TransactionDetections extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v7())();
  TextColumn get sourcePackage => text()();
  TextColumn get type => text().map(const EnumNameConverter(DetectionTransactionType.values))();
  IntColumn get amount => integer()();
  TextColumn get merchant => text().nullable()();
  TextColumn get counterparty => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get accountId => text().nullable().references(Accounts, #id, onDelete: KeyAction.setNull)();
  RealColumn get confidence => real()();
  TextColumn get confidenceTier => text().map(const EnumNameConverter(ConfidenceTier.values))();
  TextColumn get method => text().map(const EnumNameConverter(PaymentMethod.values))();
  TextColumn get parserVersion => text()();
  TextColumn get status =>
      text().map(const EnumNameConverter(DetectionStatus.values)).withDefault(const Constant('pending'))();
  TextColumn get fingerprint => text().unique()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Learned merchant-to-category mapping from user review decisions.
class MerchantCategoryRules extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v7())();
  TextColumn get merchantNormalized => text().unique()();
  TextColumn get categoryId => text().references(Categories, #id, onDelete: KeyAction.cascade)();
  IntColumn get hitCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stable profile of a recurring income event believed to be salary.
class SalaryProfiles extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v7())();
  IntColumn get amount => integer().nullable()();
  IntColumn get dayOfMonth => integer().nullable()();
  RealColumn get averageConfidence => real().withDefault(const Constant(0))();
  IntColumn get occurrenceCount => integer().withDefault(const Constant(0))();
  TextColumn get sourcePackage => text().nullable()();
  DateTimeColumn get lastDetectedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
