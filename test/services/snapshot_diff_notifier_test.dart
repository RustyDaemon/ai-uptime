import 'package:flutter_test/flutter_test.dart';

import 'package:ai_uptime/config.dart';
import 'package:ai_uptime/models/status_indicator.dart';
import 'package:ai_uptime/services/snapshot_diff_notifier.dart';

import '../test_helpers.dart';

void main() {
  test('first load sends no alerts and records seen incidents', () async {
    final notifications = FakeNotificationService();
    final store = MemorySettingsStore();
    final notifier = SnapshotDiffNotifier(
      notifications: notifications,
      settingsStore: store,
    );
    final incident = testIncident();
    final snapshot = testAppSnapshot(
      services: [
        testServiceSnapshot(activeIncidents: [incident]),
      ],
    );

    await notifier.processTransition(
      previous: null,
      next: snapshot,
      settings: testSettings(),
    );

    expect(notifications.calls, isEmpty);
    expect(store.seenIncidentIds, contains(incident.id));
  });

  test('new incident alerts once after a prior snapshot exists', () async {
    final notifications = FakeNotificationService();
    final notifier = SnapshotDiffNotifier(
      notifications: notifications,
      settingsStore: MemorySettingsStore(),
    );
    final previous = testAppSnapshot(
      services: [testServiceSnapshot(activeIncidents: const [])],
    );
    final incident = testIncident(id: 'incident-new');
    final next = testAppSnapshot(
      services: [
        testServiceSnapshot(activeIncidents: [incident]),
      ],
    );

    await notifier.processTransition(
      previous: null,
      next: previous,
      settings: testSettings(),
    );
    await notifier.processTransition(
      previous: previous,
      next: next,
      settings: testSettings(),
    );
    await notifier.processTransition(
      previous: next,
      next: next,
      settings: testSettings(),
    );

    expect(notifications.calls, hasLength(1));
    expect(notifications.calls.single.title, 'OpenAI: New incident');
  });

  test('resolved incident alerts once', () async {
    final notifications = FakeNotificationService();
    final notifier = SnapshotDiffNotifier(
      notifications: notifications,
      settingsStore: MemorySettingsStore(),
    );
    final incident = testIncident(id: 'incident-resolved');
    final previous = testAppSnapshot(
      services: [
        testServiceSnapshot(activeIncidents: [incident]),
      ],
    );
    final next = testAppSnapshot(
      services: [
        testServiceSnapshot(
          activeIncidents: const [],
          recentIncidents: [
            testIncident(id: 'incident-resolved', status: 'resolved'),
          ],
        ),
      ],
    );

    await notifier.processTransition(
      previous: previous,
      next: next,
      settings: testSettings(),
    );
    await notifier.processTransition(
      previous: previous,
      next: next,
      settings: testSettings(),
    );

    expect(notifications.calls, hasLength(1));
    expect(notifications.calls.single.title, 'OpenAI: Incident resolved');
  });

  test(
    'component status change requires a prior successful snapshot',
    () async {
      final notifications = FakeNotificationService();
      final notifier = SnapshotDiffNotifier(
        notifications: notifications,
        settingsStore: MemorySettingsStore(),
      );
      final next = testAppSnapshot(
        services: [
          testServiceSnapshot(
            components: [testComponent(status: StatusIndicator.degraded)],
          ),
        ],
      );

      await notifier.processTransition(
        previous: null,
        next: next,
        settings: testSettings(),
      );
      await notifier.processTransition(
        previous: testAppSnapshot(
          services: [
            testServiceSnapshot(
              components: [testComponent()],
              error: 'offline',
            ),
          ],
        ),
        next: next,
        settings: testSettings(),
      );
      await notifier.processTransition(
        previous: testAppSnapshot(),
        next: next,
        settings: testSettings(),
      );

      expect(notifications.calls, hasLength(1));
      expect(notifications.calls.single.title, 'OpenAI: API');
    },
  );

  test('region or filter changes reset comparison state', () async {
    final notifications = FakeNotificationService();
    final notifier = SnapshotDiffNotifier(
      notifications: notifications,
      settingsStore: MemorySettingsStore(),
    );
    final previous = testAppSnapshot(
      services: [testServiceSnapshot(activeIncidents: const [])],
    );
    final next = testAppSnapshot(
      services: [
        testServiceSnapshot(
          activeIncidents: [testIncident(id: 'incident-reset')],
        ),
      ],
    );

    await notifier.processTransition(
      previous: null,
      next: previous,
      settings: testSettings(),
    );
    await notifier.processTransition(
      previous: previous,
      next: next,
      settings: testSettings(githubRegion: GitHubRegion.us),
    );

    expect(notifications.calls, isEmpty);
  });
}
