import '../models/app_snapshot.dart';
import '../models/component.dart';
import '../models/incident.dart';
import '../models/service.dart';
import '../models/service_snapshot.dart';
import 'notification_service.dart';
import 'settings_store.dart';

class SnapshotDiffNotifier {
  final NotificationService notifications;
  final SettingsStore settingsStore;

  Set<String>? _seenIncidentIds;
  final Set<String> _notifiedResolved = <String>{};
  String? _lastComparisonKey;

  SnapshotDiffNotifier({
    required this.notifications,
    required this.settingsStore,
  });

  Future<void> processTransition({
    AppSnapshot? previous,
    required AppSnapshot next,
    required AppSettings settings,
  }) async {
    await _ensureLoaded();

    final comparisonKey = _comparisonKeyFor(settings);
    final effectivePrevious = _lastComparisonKey == comparisonKey
        ? previous
        : null;
    _lastComparisonKey = comparisonKey;

    for (final serviceSnapshot in next.services) {
      if (serviceSnapshot.error != null) continue;

      final previousService = _findServiceSnapshot(
        effectivePrevious,
        serviceSnapshot.service.id,
      );

      if (settings.notifyOnComponentChange &&
          previousService != null &&
          previousService.error == null) {
        final previousByName = {
          for (final component in previousService.components)
            component.name: component,
        };
        for (final component in serviceSnapshot.components) {
          final previousComponent = previousByName[component.name];
          if (previousComponent != null &&
              previousComponent.status != component.status) {
            await _fireComponentChange(
              serviceSnapshot.service,
              component,
              previousComponent,
            );
          }
        }
      }

      for (final incident in serviceSnapshot.activeIncidents) {
        final alreadySeen = _seenIncidentIds!.contains(incident.id);
        if (!alreadySeen) {
          _seenIncidentIds!.add(incident.id);
          if (effectivePrevious != null && settings.notifyOnNewIncident) {
            await _fireNewIncident(serviceSnapshot.service, incident);
          }
        }
      }

      if (settings.notifyOnResolved &&
          previousService != null &&
          previousService.error == null) {
        final previousActive = {
          for (final incident in previousService.activeIncidents)
            incident.id: incident,
        };
        final nowResolved = serviceSnapshot.recentIncidents.where(
          (incident) => previousActive.containsKey(incident.id),
        );
        for (final incident in nowResolved) {
          if (_notifiedResolved.add(incident.id)) {
            await _fireIncidentResolved(serviceSnapshot.service, incident);
          }
        }
      }
    }

    await settingsStore.saveSeenIncidentIds(_seenIncidentIds!);
  }

  Future<void> _ensureLoaded() async {
    _seenIncidentIds ??= await settingsStore.loadSeenIncidentIds();
  }

  ServiceSnapshot? _findServiceSnapshot(
    AppSnapshot? snapshot,
    String serviceId,
  ) {
    if (snapshot == null) return null;
    for (final service in snapshot.services) {
      if (service.service.id == serviceId) {
        return service;
      }
    }
    return null;
  }

  String _comparisonKeyFor(AppSettings settings) {
    final entries = settings.hiddenComponentIds.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final hidden = entries
        .map((entry) {
          final ids = entry.value.toList()..sort();
          return '${entry.key}:${ids.join(",")}';
        })
        .join('|');
    return '${settings.githubRegion.id}#$hidden';
  }

  Future<void> _fireNewIncident(MonitoredService service, Incident incident) {
    return notifications.show(
      title: '${service.name}: New incident',
      body: incident.name,
      payload: incident.shortlink.isEmpty
          ? service.publicUrl
          : incident.shortlink,
    );
  }

  Future<void> _fireComponentChange(
    MonitoredService service,
    Component current,
    Component previous,
  ) {
    return notifications.show(
      title: '${service.name}: ${current.name}',
      body: '${previous.status.label} → ${current.status.label}',
      payload: service.publicUrl,
    );
  }

  Future<void> _fireIncidentResolved(
    MonitoredService service,
    Incident incident,
  ) {
    return notifications.show(
      title: '${service.name}: Incident resolved',
      body: incident.name,
      payload: incident.shortlink.isEmpty
          ? service.publicUrl
          : incident.shortlink,
    );
  }
}
