import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../config.dart';
import '../models/app_snapshot.dart';
import '../services/notification_service.dart';
import '../services/poller.dart';
import '../services/settings_store.dart';
import '../services/snapshot_diff_notifier.dart';
import '../services/status_api_client.dart';
import '../services/tray_service.dart';
import '../ui/tokens.dart';
import 'app_status_controller.dart';

typedef CreatePoller = Poller Function(AppSettings initialSettings);

final apiClientProvider = Provider<StatusApiClient>((ref) {
  final client = StatusApiClient();
  ref.onDispose(client.dispose);
  return client;
});

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final trayServiceProvider = Provider<TrayService>((ref) => TrayService());

final settingsStoreProvider = Provider<SettingsStore>((ref) => SettingsStore());

final snapshotDiffNotifierProvider = Provider<SnapshotDiffNotifier>((ref) {
  return SnapshotDiffNotifier(
    notifications: ref.read(notificationServiceProvider),
    settingsStore: ref.read(settingsStoreProvider),
  );
});

final pollerFactoryProvider = Provider<CreatePoller>((ref) {
  return (initialSettings) => Poller(
    apiClient: ref.read(apiClientProvider),
    initialSettings: initialSettings,
  );
});

final settingsProvider = StateNotifierProvider<SettingsController, AppSettings>(
  (ref) {
    return SettingsController(ref.read(settingsStoreProvider));
  },
);

class SettingsController extends StateNotifier<AppSettings> {
  final SettingsStore _store;

  SettingsController(this._store) : super(const AppSettings.defaults()) {
    _load();
  }

  Future<void> _load() async {
    state = await _store.load();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) {
    return _persist(state.copyWith(themeMode: themeMode));
  }

  Future<void> setTextScale(AppTextScale textScale) {
    return _persist(state.copyWith(textScale: textScale));
  }

  Future<void> setPollInterval(int pollIntervalSeconds) {
    return _persist(state.copyWith(pollIntervalSeconds: pollIntervalSeconds));
  }

  Future<void> setGitHubRegion(GitHubRegion githubRegion) {
    return _persist(state.copyWith(githubRegion: githubRegion));
  }

  Future<void> setNotifyOnNewIncident(bool value) {
    return _persist(state.copyWith(notifyOnNewIncident: value));
  }

  Future<void> setNotifyOnComponentChange(bool value) {
    return _persist(state.copyWith(notifyOnComponentChange: value));
  }

  Future<void> setNotifyOnResolved(bool value) {
    return _persist(state.copyWith(notifyOnResolved: value));
  }

  Future<void> setComponentVisibility(
    String serviceId,
    String componentId,
    bool visible,
  ) {
    final nextMap = <String, Set<String>>{
      for (final entry in state.hiddenComponentIds.entries)
        entry.key: Set<String>.from(entry.value),
    };
    final current = nextMap.putIfAbsent(serviceId, () => <String>{});
    if (visible) {
      current.remove(componentId);
    } else {
      current.add(componentId);
    }
    if (current.isEmpty) {
      nextMap.remove(serviceId);
    }
    return _persist(state.copyWith(hiddenComponentIds: nextMap));
  }

  Future<void> _persist(AppSettings next) async {
    state = next;
    await _store.save(next);
  }
}

final pollerProvider = Provider<Poller>((ref) {
  final poller = ref.read(pollerFactoryProvider)(ref.read(settingsProvider));
  ref.listen<AppSettings>(
    settingsProvider,
    (_, next) => poller.updateSettings(next),
  );
  ref.onDispose(poller.stop);
  return poller;
});

final appStatusControllerProvider =
    StateNotifierProvider<AppStatusController, AppSnapshot>((ref) {
      return AppStatusController(
        poller: ref.read(pollerProvider),
        notificationService: ref.read(notificationServiceProvider),
        trayService: ref.read(trayServiceProvider),
        snapshotDiffNotifier: ref.read(snapshotDiffNotifierProvider),
        readSettings: () => ref.read(settingsProvider),
      );
    });

final snapshotProvider = Provider<AppSnapshot>((ref) {
  return ref.watch(appStatusControllerProvider);
});
