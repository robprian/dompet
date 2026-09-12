import 'package:dompet/core/utils/icon_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui_phosphor/forui_phosphor.dart';

void main() {
  group('IconUtil', () {
    test('contains the finance icon catalogue', () {
      expect(IconUtil.categories, isNotEmpty);
      expect(IconUtil.availableIcons, containsPair('wallet', FPhosphorIcons.wallet));
      expect(IconUtil.availableIcons, containsPair('bca', FPhosphorIcons.bank));
    });

    test('falls back to a wallet icon for unknown values', () {
      expect(IconUtil.getIcon(null), FPhosphorIcons.wallet);
      expect(IconUtil.getIcon('unknown_icon'), FPhosphorIcons.wallet);
    });

    test('provides brand marks for supported banks and e-wallets', () {
      expect(IconUtil.getBrandMark('bca'), 'BCA');
      expect(IconUtil.getBrandMark('gopay'), 'G');
      expect(IconUtil.getBrandMark('unknown'), isEmpty);
    });
  });
}
