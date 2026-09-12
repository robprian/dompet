import 'package:dompet/core/utils/icon_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('provider catalogue is grouped by bank, e-wallet, and investment', () {
    expect(IconUtil.providersOf(AccountProviderType.bank), isNotEmpty);
    expect(IconUtil.providersOf(AccountProviderType.ewallet), isNotEmpty);
    expect(IconUtil.providersOf(AccountProviderType.investment), isNotEmpty);
    expect(IconUtil.accountProviders.every((provider) => provider.assetPath.contains('/images/')), isTrue);
  });
}
