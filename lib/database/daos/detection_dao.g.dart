// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_dao.dart';

// ignore_for_file: type=lint
mixin _$DetectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $TransactionDetectionsTable get transactionDetections => attachedDatabase.transactionDetections;
  $MerchantCategoryRulesTable get merchantCategoryRules => attachedDatabase.merchantCategoryRules;
  $SalaryProfilesTable get salaryProfiles => attachedDatabase.salaryProfiles;
  DetectionDaoManager get managers => DetectionDaoManager(this);
}

class DetectionDaoManager {
  final _$DetectionDaoMixin _db;
  DetectionDaoManager(this._db);
  $$CategoriesTableTableManager get categories => $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$AccountsTableTableManager get accounts => $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$TransactionDetectionsTableTableManager get transactionDetections => $$TransactionDetectionsTableTableManager(
    _db.attachedDatabase,
    _db.transactionDetections,
  );
  $$MerchantCategoryRulesTableTableManager get merchantCategoryRules => $$MerchantCategoryRulesTableTableManager(
    _db.attachedDatabase,
    _db.merchantCategoryRules,
  );
  $$SalaryProfilesTableTableManager get salaryProfiles => $$SalaryProfilesTableTableManager(
    _db.attachedDatabase,
    _db.salaryProfiles,
  );
}
