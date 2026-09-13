import 'package:dompet/app/shell/startup_gate.dart';
import 'package:dompet/features/settings/domain/settings_model.dart';
import 'package:dompet/features/settings/presentation/controllers/settings_notifier.dart';
import 'package:dompet/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _StubSettings extends SettingsNotifier {
  _StubSettings(this._state);

  final SettingsState _state;

  @override
  SettingsState build() => _state;
}

Widget _host(SettingsState state) {
  return ProviderScope(
    overrides: [settingsProvider.overrideWith(() => _StubSettings(state))],
    child: FTheme(
      data: lightTheme,
      child: const MaterialApp(
        home: FScaffold(child: StartupGate(child: Text('finance'))),
      ),
    ),
  );
}

void main() {
  testWidgets('shows progress while settings load', (tester) async {
    await tester.pumpWidget(_host(const SettingsState(isLoading: true)));

    expect(find.text('finance'), findsNothing);
    expect(find.byType(FCircularProgress), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('reveals child once settings resolve', (tester) async {
    await tester.pumpWidget(
      _host(const SettingsState(settings: SettingsModel(themeMode: 'system'))),
    );

    expect(find.text('finance'), findsOneWidget);
    expect(find.byType(FCircularProgress), findsNothing);
  });

  testWidgets('reveals child after a non-loading failure so router can route', (tester) async {
    await tester.pumpWidget(_host(const SettingsState(error: 'boom')));

    expect(find.text('finance'), findsOneWidget);
  });
}
