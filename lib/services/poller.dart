import 'dart:async';

import '../config.dart';
import '../models/app_snapshot.dart';
import '../models/incident.dart';
import '../models/service_snapshot.dart';
import 'settings_store.dart';
import 'status_api_client.dart';

typedef SnapshotListener = FutureOr<void> Function(AppSnapshot snapshot);

class Poller {
  final StatusApiClient apiClient;

  AppSettings _settings;
  Timer? _timer;
  final List<SnapshotListener> _listeners = [];
  bool _fetching = false;

  Poller({required this.apiClient, required AppSettings initialSettings})
    : _settings = initialSettings;

  void addListener(SnapshotListener listener) => _listeners.add(listener);
  void removeListener(SnapshotListener listener) => _listeners.remove(listener);

  Future<void> start() async {
    await refreshNow();
    _scheduleNext();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void updateSettings(AppSettings next) {
    final intervalChanged =
        next.pollIntervalSeconds != _settings.pollIntervalSeconds;
    final regionChanged = next.githubRegion != _settings.githubRegion;
    final filtersChanged = !_hiddenMapEquals(
      next.hiddenComponentIds,
      _settings.hiddenComponentIds,
    );
    _settings = next;
    if (intervalChanged) {
      _timer?.cancel();
      _scheduleNext();
    }
    if (regionChanged || filtersChanged) {
      refreshNow();
    }
  }

  static bool _hiddenMapEquals(
    Map<String, Set<String>> a,
    Map<String, Set<String>> b,
  ) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final other = b[entry.key];
      if (other == null) return false;
      if (other.length != entry.value.length) return false;
      if (!other.containsAll(entry.value)) return false;
    }
    return true;
  }

  void _scheduleNext() {
    _timer = Timer(Duration(seconds: _settings.pollIntervalSeconds), () async {
      await refreshNow();
      _scheduleNext();
    });
  }

  Future<void> refreshNow() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final services = monitoredServices(_settings.githubRegion);
      final results = await Future.wait(services.map(apiClient.fetch));
      final filtered = [
        for (final result in results)
          _applyComponentFilter(
            result,
            _settings.hiddenIdsFor(result.service.id),
          ),
      ];
      final snapshot = AppSnapshot(
        services: filtered,
        fetchedAt: DateTime.now(),
      );
      for (final listener in List<SnapshotListener>.from(_listeners)) {
        await listener(snapshot);
      }
    } finally {
      _fetching = false;
    }
  }

  ServiceSnapshot _applyComponentFilter(
    ServiceSnapshot snapshot,
    Set<String> hiddenIds,
  ) {
    if (hiddenIds.isEmpty) return snapshot;

    final kept = snapshot.components
        .where((component) => !hiddenIds.contains(component.id))
        .toList();
    final hiddenNames = snapshot.components
        .where((component) => hiddenIds.contains(component.id))
        .map((component) => component.name.toLowerCase())
        .toSet();

    List<Incident> filterIncidents(List<Incident> incidents) {
      return incidents.where((incident) {
        if (incident.affectedComponentNames.isEmpty) return true;
        return incident.affectedComponentNames.any(
          (name) => !hiddenNames.contains(name.toLowerCase()),
        );
      }).toList();
    }

    return ServiceSnapshot(
      service: snapshot.service,
      indicator: snapshot.indicator,
      indicatorDescription: snapshot.indicatorDescription,
      components: kept,
      allComponents: snapshot.allComponents,
      activeIncidents: filterIncidents(snapshot.activeIncidents),
      recentIncidents: filterIncidents(snapshot.recentIncidents),
      fetchedAt: snapshot.fetchedAt,
      error: snapshot.error,
    );
  }
}
