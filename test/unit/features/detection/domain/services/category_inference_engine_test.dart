import 'package:dompet/features/detection/domain/services/category_inference_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryInferenceEngine', () {
    test('maps known merchants locally', () {
      final engine = CategoryInferenceEngine();
      expect(engine.infer('PLN Prabayar')?.label, 'Utilities');
      expect(engine.infer('KOPI KENANGAN STC')?.label, 'Food & Dining');
      expect(engine.infer('Netflix')?.label, 'Subscription / Entertainment');
      expect(engine.infer('Tokopedia')?.label, 'Shopping');
      expect(engine.infer('Telkomsel')?.label, 'Mobile / Internet');
      expect(engine.infer('GrabBike')?.label, 'Transport');
      expect(engine.infer('Apotek Kimia Farma')?.label, 'Health');
    });

    test('reports high confidence for long merchant matches', () {
      final inference = CategoryInferenceEngine().infer('KOPI KENANGAN STC');
      expect(inference?.confidence, greaterThanOrEqualTo(0.9));
    });

    test('returns null for unknown merchants', () {
      expect(CategoryInferenceEngine().infer('Toko Tak Dikenal XYZ'), isNull);
      expect(CategoryInferenceEngine().infer(null), isNull);
      expect(CategoryInferenceEngine().infer(''), isNull);
      expect(CategoryInferenceEngine().infer('   '), isNull);
    });

    test('learned rules override defaults', () {
      final engine = CategoryInferenceEngine();
      engine.learn(merchant: 'Toko Tak Dikenal XYZ', category: 'Shopping');
      expect(engine.infer('Toko Tak Dikenal XYZ kondangan')?.label, 'Shopping');
    });

    test('accepts custom rule sets', () {
      final engine = CategoryInferenceEngine(rules: const {'warteg': 'Food & Dining'});
      expect(engine.infer('Warteg Bahari')?.label, 'Food & Dining');
    });
  });
}
