import 'component.dart';
import 'incident.dart';
import 'service.dart';
import 'status_indicator.dart';

class ServiceSnapshot {
  final MonitoredService service;
  final StatusIndicator indicator;
  final String? indicatorDescription;
  final List<Component> components;
  final List<Component> allComponents;
  final List<Incident> activeIncidents;
  final List<Incident> recentIncidents;
  final DateTime fetchedAt;
  final String? error;

  const ServiceSnapshot({
    required this.service,
    required this.indicator,
    required this.indicatorDescription,
    required this.components,
    required this.allComponents,
    required this.activeIncidents,
    required this.recentIncidents,
    required this.fetchedAt,
    required this.error,
  });

  factory ServiceSnapshot.error(MonitoredService service, String error) {
    return ServiceSnapshot(
      service: service,
      indicator: StatusIndicator.unknown,
      indicatorDescription: null,
      components: const [],
      allComponents: const [],
      activeIncidents: const [],
      recentIncidents: const [],
      fetchedAt: DateTime.now(),
      error: error,
    );
  }

  StatusIndicator get effectiveIndicator {
    final fromComponents = StatusIndicator.worstOf(
      components.map((c) => c.status),
    );
    final fromIncidents = StatusIndicator.worstOf(
      activeIncidents.map((i) => i.impact),
    );
    return StatusIndicator.worstOf([indicator, fromComponents, fromIncidents]);
  }
}
