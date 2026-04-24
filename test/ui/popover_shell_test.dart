import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_uptime/state/providers.dart';
import 'package:ai_uptime/ui/popover_shell.dart';
import 'package:ai_uptime/ui/settings_view.dart';
import 'package:ai_uptime/ui/widgets/app_icon_button.dart';
import 'package:ai_uptime/ui/widgets/app_root.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('SettingsView builds without reading pollerProvider directly', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = FakeAppStatusController(snapshot: testAppSnapshot());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appStatusControllerProvider.overrideWith((ref) => controller),
          pollerProvider.overrideWith((ref) {
            throw StateError(
              'pollerProvider should not be read by SettingsView',
            );
          }),
        ],
        child: const AppRoot(child: SettingsView()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Status page'), findsOneWidget);
  });

  testWidgets('refresh button delegates to the app status controller', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = FakeAppStatusController(snapshot: testAppSnapshot());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appStatusControllerProvider.overrideWith((ref) => controller),
        ],
        child: const AppRoot(child: PopoverShell()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppIconButton).first);
    await tester.pump();

    expect(controller.refreshNowCount, 1);
  });
}
