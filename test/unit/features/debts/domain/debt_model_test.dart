import 'package:flutter_test/flutter_test.dart';
import 'package:dompet/core/enums.dart';
import 'package:dompet/features/debts/domain/debt_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('DebtModel', () {
    test('fromJson/toJson', () {
      final now = DateTime.utc(2024, 1, 1);
      final m = DebtModel(
        id: 'd1',
        personName: 'Alice',
        type: DebtType.debt,
        amount: 1000,
        remainingAmount: 500,
        status: DebtStatus.active,
        createdAt: now,
        updatedAt: now,
        dueDate: now,
        note: 'note',
      );
      final json = m.toJson();
      final restored = DebtModel.fromJson(json);
      expect(restored, equals(m));
    });

    test('copyWith', () {
      final now = DateTime.utc(2024, 1, 1);
      final m = DebtModel(
        id: 'd1',
        personName: 'Alice',
        type: DebtType.debt,
        amount: 1000,
        remainingAmount: 1000,
        status: DebtStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      final c = m.copyWith(personName: 'Bob', status: DebtStatus.paid);
      expect(c.personName, 'Bob');
      expect(c.status, DebtStatus.paid);
    });

    test('equality', () {
      final now = DateTime.utc(2024, 1, 1);
      final a = DebtModel(
        id: 'd1',
        personName: 'Alice',
        type: DebtType.loan,
        amount: 1000,
        remainingAmount: 1000,
        status: DebtStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      final b = DebtModel(
        id: 'd1',
        personName: 'Alice',
        type: DebtType.loan,
        amount: 1000,
        remainingAmount: 1000,
        status: DebtStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      expect(a, equals(b));
    });
  });
}
