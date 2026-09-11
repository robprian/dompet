import 'package:dompet/shared/widgets/dompet_brand_mark.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(
  builder: (context, c) => FTheme(data: lightTheme, child: c!),
  home: Scaffold(body: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DompetBrandMark', () {
    testWidgets('renders the logo asset', (t) async {
      await t.pumpWidget(wrap(const DompetBrandMark()));
      final image = t.widget<Image>(find.byType(Image));
      final provider = image.image;
      expect(provider, isA<AssetImage>());
      expect((provider as AssetImage).assetName, 'assets/images/logo.png');
    });

    testWidgets('respects the configured size', (t) async {
      await t.pumpWidget(wrap(const DompetBrandMark(size: 64)));
      final container = t.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 64);
      expect(container.constraints?.maxHeight, 64);
    });
  });
}
