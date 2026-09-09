import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dompet/database/database.dart';

import '../../database/schema.dart';
import '../../database/schema_v1.dart' as v1;
import '../../database/schema_v2.dart' as v2;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test(
    'verify schema v1 matches current database definition',
    () async {
      final connection = await verifier.startAt(1);
      final db = AppDatabase(connection: connection);
      await verifier.migrateAndValidate(db, 1);
      await db.close();
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );

  test(
    'migration preserves data while adding detection tables',
    () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: (executor) => AppDatabase(connection: executor),
        createItems: (batch, oldDb) {
          batch.customStatement(
            "INSERT INTO accounts (id, name, type) VALUES ('acc-migrate', 'Legacy Wallet', 'assets')",
          );
        },
        validateItems: (newDb) async {
          final accounts = await newDb.customSelect('SELECT id FROM accounts').get();
          expect(accounts.map((row) => row.read<String>('id')), contains('acc-migrate'));
          expect(await newDb.customSelect('SELECT id FROM transaction_detections').get(), isEmpty);
          expect(await newDb.customSelect('SELECT id FROM merchant_category_rules').get(), isEmpty);
          expect(await newDb.customSelect('SELECT id FROM salary_profiles').get(), isEmpty);
        },
      );
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );

  test(
    'fresh database validates against generated schema expectations',
    () async {
      final db = AppDatabase(connection: NativeDatabase.memory());
      await db.customSelect('SELECT 1').get();
      await db.validateDatabaseSchema();
      await db.close();
    },
    timeout: const Timeout(Duration(seconds: 5)),
  );
}
