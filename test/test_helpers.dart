import 'package:ai_uptime/config.dart';
import 'package:ai_uptime/models/app_snapshot.dart';
import 'package:ai_uptime/models/component.dart';
import 'package:ai_uptime/models/incident.dart';
import 'package:ai_uptime/models/service.dart';
import 'package:ai_uptime/models/service_snapshot.dart';
import 'package:ai_uptime/models/status_indicator.dart';
import 'package:ai_uptime/services/notification_service.dart';
import 'package:ai_uptime/services/poller.dart';
import 'package:ai_uptime/services/settings_store.dart';
import 'package:ai_uptime/services/snapshot_diff_notifier.dart';
import 'package:ai_uptime/services/status_api_client.dart';
import 'package:ai_uptime/services/tray_service.dart';
import 'package:ai_uptime/state/app_status_controller.dart';
import 'package:ai_uptime/ui/tokens.dart';

class NotificationCall {
  final String title;
  final String body;
  final String? payload;

  const NotificationCall({
    required this.title,
    required this.body,
    required this.payload,
  });
}

class FakeNotificationService extends NotificationService {
  int initCount = 0;
  final List<NotificationCall> calls = <NotificationCall>[];

  @override
  Future<void> init() async {
    initCount++;
  }

  @override
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    calls.add(NotificationCall(title: title, body: body, payload: payload));
  }
}

class MemorySettingsStore extends SettingsStore {
  AppSettings storedSettings;
  Set<String> seenIncidentIds;

  MemorySettingsStore({
    AppSettings? initialSettings,
    Set<String>? initialSeenIncidentIds,
  }) : storedSettings = initialSettings ?? const AppSettings.defaults(),
       seenIncidentIds = initialSeenIncidentIds ?? <String>{};

  @override
  Future<AppSettings> load() async => storedSettings;

  @override
  Future<void> save(AppSettings settings) async {
    storedSettings = settings;
  }

  @override
  Future<Set<String>> loadSeenIncidentIds() async =>
      Set<String>.from(seenIncidentIds);

  @override
  Future<void> saveSeenIncidentIds(Set<String> ids) async {
    seenIncidentIds = Set<String>.from(ids);
  }
}

class FakeTrayService extends TrayService {
  int initCount = 0;
  final List<AppSnapshot> updates = <AppSnapshot>[];

  @override
  Future<void> init() async {
    initCount++;
  }

  @override
  Future<void> update(AppSnapshot snapshot) async {
    updates.add(snapshot);
  }
}

class FakeSnapshotDiffNotifier extends SnapshotDiffNotifier {
  int callCount = 0;
  AppSnapshot? previous;
  AppSnapshot? next;
  AppSettings? settings;

  FakeSnapshotDiffNotifier()
    : super(
        notifications: FakeNotificationService(),
        settingsStore: MemorySettingsStore(),
      );

  @override
  Future<void> processTransition({
    AppSnapshot? previous,
    required AppSnapshot next,
    required AppSettings settings,
  }) async {
    callCount++;
    this.previous = previous;
    this.next = next;
    this.settings = settings;
  }
}

class FakePoller extends Poller {
  final List<SnapshotListener> _listeners = <SnapshotListener>[];
  final List<AppSettings> updatedSettings = <AppSettings>[];

  int startCount = 0;
  int refreshCount = 0;
  int stopCount = 0;
  AppSnapshot? snapshotOnStart;
  AppSnapshot? snapshotOnRefresh;

  FakePoller({
    AppSettings? initialSettings,
    this.snapshotOnStart,
    this.snapshotOnRefresh,
  }) : super(
         apiClient: StatusApiClient(),
         initialSettings: initialSettings ?? const AppSettings.defaults(),
       );

  @override
  void addListener(SnapshotListener listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(SnapshotListener listener) {
    _listeners.remove(listener);
  }

  @override
  Future<void> start() async {
    startCount++;
    if (snapshotOnStart != null) {
      await emit(snapshotOnStart!);
    }
  }

  @override
  Future<void> refreshNow() async {
    refreshCount++;
    if (snapshotOnRefresh != null) {
      await emit(snapshotOnRefresh!);
    }
  }

  @override
  void stop() {
    stopCount++;
  }

  @override
  void updateSettings(AppSettings next) {
    updatedSettings.add(next);
  }

  Future<void> emit(AppSnapshot snapshot) async {
    for (final listener in List<SnapshotListener>.from(_listeners)) {
      await listener(snapshot);
    }
  }
}

class FakeAppStatusController extends AppStatusController {
  int refreshNowCount = 0;

  FakeAppStatusController({
    required AppSnapshot snapshot,
    AppSettings? settings,
  }) : super(
         poller: FakePoller(initialSettings: settings),
         notificationService: FakeNotificationService(),
         trayService: FakeTrayService(),
         snapshotDiffNotifier: FakeSnapshotDiffNotifier(),
         readSettings: () => settings ?? const AppSettings.defaults(),
       ) {
    state = snapshot;
  }

  @override
  Future<void> refreshNow() async {
    refreshNowCount++;
  }
}

MonitoredService testService({String id = 'openai', String name = 'OpenAI'}) {
  return MonitoredService(
    id: id,
    name: name,
    baseUrl: 'https://status.example.com/$id',
    componentFilter: null,
  );
}

Component testComponent({
  String id = 'component-1',
  String name = 'API',
  StatusIndicator status = StatusIndicator.operational,
}) {
  return Component(id: id, name: name, description: null, status: status);
}

Incident testIncident({
  String id = 'incident-1',
  String name = 'Incident',
  String status = 'investigating',
  StatusIndicator impact = StatusIndicator.degraded,
}) {
  final now = DateTime.utc(2026, 1, 1, 12);
  return Incident(
    id: id,
    name: name,
    status: status,
    impact: impact,
    createdAt: now,
    resolvedAt: status == 'resolved' ? now : null,
    updatedAt: now,
    shortlink: 'https://status.example.com/incidents/$id',
    affectedComponentNames: const <String>['API'],
    updates: const <IncidentUpdate>[],
  );
}

ServiceSnapshot testServiceSnapshot({
  MonitoredService? service,
  StatusIndicator indicator = StatusIndicator.operational,
  List<Component>? components,
  List<Component>? allComponents,
  List<Incident>? activeIncidents,
  List<Incident>? recentIncidents,
  String? error,
}) {
  final serviceValue = service ?? testService();
  final componentsValue = components ?? <Component>[testComponent()];
  return ServiceSnapshot(
    service: serviceValue,
    indicator: indicator,
    indicatorDescription: null,
    components: componentsValue,
    allComponents: allComponents ?? componentsValue,
    activeIncidents: activeIncidents ?? const <Incident>[],
    recentIncidents: recentIncidents ?? const <Incident>[],
    fetchedAt: DateTime.utc(2026, 1, 1, 12),
    error: error,
  );
}

AppSnapshot testAppSnapshot({
  List<ServiceSnapshot>? services,
  DateTime? fetchedAt,
}) {
  return AppSnapshot(
    services: services ?? <ServiceSnapshot>[testServiceSnapshot()],
    fetchedAt: fetchedAt ?? DateTime.utc(2026, 1, 1, 12),
  );
}

AppSettings testSettings({
  int pollIntervalSeconds = 60,
  bool notifyOnNewIncident = true,
  bool notifyOnComponentChange = true,
  bool notifyOnResolved = true,
  GitHubRegion githubRegion = GitHubRegion.eu,
  AppThemeMode themeMode = AppThemeMode.dark,
  AppTextScale textScale = AppTextScale.medium,
  Map<String, Set<String>> hiddenComponentIds = const <String, Set<String>>{},
}) {
  return AppSettings(
    pollIntervalSeconds: pollIntervalSeconds,
    notifyOnNewIncident: notifyOnNewIncident,
    notifyOnComponentChange: notifyOnComponentChange,
    notifyOnResolved: notifyOnResolved,
    githubRegion: githubRegion,
    themeMode: themeMode,
    textScale: textScale,
    hiddenComponentIds: hiddenComponentIds,
  );
}
