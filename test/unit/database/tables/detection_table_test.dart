import 'package:drift/native.dart';
import 'package:dompet/database/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('detection tables expose the expected columns', () async {
    final db = AppDatabase(connection: NativeDatabase.memory());
    addTearDown(db.close);

    final detections = await db.customSelect('PRAGMA table_info(transaction_detections)').get();
    final detectionColumns = detections.map((row) => row.read<String>('name')).toSet();
    expect(
      detectionColumns,
      containsAll([
        'id',
        'source_package',
        'type',
        'amount',
        'merchant',
        'counterparty',
        'reference_id',
        'category_id',
        'account_id',
        'confidence',
        'confidence_tier',
        'method',
        'parser_version',
        'status',
        'fingerprint',
        'occurred_at',
      ]),
    );

    final rules = await db.customSelect('PRAGMA table_info(merchant_category_rules)').get();
    expect(
      rules.map((row) => row.read<String>('name')).toSet(),
      containsAll(['merchant_normalized', 'category_id', 'hit_count']),
    );

    final salaries = await db.customSelect('PRAGMA table_info(salary_profiles)').get();
    expect(
      salaries.map((row) => row.read<String>('name')).toSet(),
      containsAll(['amount', 'day_of_month', 'average_confidence', 'occurrence_count', 'last_detected_at']),
    );
  });
}
