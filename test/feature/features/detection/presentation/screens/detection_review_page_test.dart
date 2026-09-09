import 'package:dompet/app/providers/repository_providers.dart';
import 'package:dompet/features/categories/domain/category_model.dart';
import 'package:dompet/features/categories/presentation/controllers/category_list_notifier.dart';
import 'package:dompet/features/dashboard/presentation/controllers/balance_visibility_provider.dart';
import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/detection_model.dart';
import 'package:dompet/features/detection/presentation/controllers/detection_review_notifier.dart';
import 'package:dompet/features/detection/presentation/screens/detection_review_page.dart';
import 'package:dompet/features/settings/presentation/controllers/settings_notifier.dart';
import 'package:dompet/i18n/strings.g.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

TransactionDetectionModel detection({String id = 'd1'}) {
  final now = DateTime.utc(2026, 3, 15, 10, 30);
  return TransactionDetectionModel(
    id: id,
    fingerprint: 'fp-$id',
    sourcePackage: 'com.bank.app',
    type: DetectionTransactionType.expense,
    amount: 25000,
    confidence: 0.95,
    confidenceTier: ConfidenceTier.high,
    method: PaymentMethod.qris,
    parserVersion: 'qris-v1',
    status: DetectionStatus.pending,
    occurredAt: now,
    createdAt: now,
    merchant: 'KOPI ABC',
  );
}

class FakeCategoryList extends CategoryListNotifier {
  @override
  Future<List<CategoryModel>> build() async => [];
}

Widget buildTestableWidget(List<TransactionDetectionModel> items) {
  return TranslationProvider(
    child: ProviderScope(
      overrides: [
        pendingDetectionsProvider.overrideWith((ref) => Stream.value(items)),
        settingsProvider.overrideWithValue(const SettingsState()),
        balanceVisibilityProvider.overrideWithValue(true),
        accountsStreamProvider.overrideWith((ref) => Stream.value(const [])),
        categoryListProvider.overrideWith(FakeCategoryList.new),
      ],
      child: MaterialApp(
        builder: (context, child) => FTheme(data: lightTheme, child: child!),
        home: const Scaffold(body: DetectionReviewPage()),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocale(AppLocale.en);

  testWidgets('review page lists pending detections', (tester) async {
    await tester.pumpWidget(buildTestableWidget([detection()]));
    await tester.pumpAndSettle();

    expect(find.text('KOPI ABC'), findsOneWidget);
    expect(find.text('QRIS'), findsOneWidget);
    expect(find.text('95%'), findsOneWidget);
  });

  testWidgets('review page shows empty state without detections', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const []));
    await tester.pumpAndSettle();

    expect(find.text('No detected transactions'), findsOneWidget);
  });

  testWidgets('tapping a detection opens the review sheet', (tester) async {
    await tester.pumpWidget(buildTestableWidget([detection()]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('KOPI ABC'));
    await tester.pumpAndSettle();

    expect(find.text('Review transaction'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Ignore'), findsOneWidget);
  });
}
