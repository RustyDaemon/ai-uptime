import '../models/component.dart';
import '../models/incident.dart';
import '../models/service.dart';
import '../models/service_snapshot.dart';
import '../models/status_indicator.dart';

class StatuspageParser {
  static ServiceSnapshot parse({
    required MonitoredService service,
    required Map<String, dynamic> summaryJson,
    required Map<String, dynamic> incidentsJson,
  }) {
    final indicatorRaw = summaryJson['status']?['indicator'] as String?;
    final indicatorDescription =
        summaryJson['status']?['description'] as String?;

    final allComponents = ((summaryJson['components'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map(_parseComponent)
        .toList();

    final allIncidents = ((incidentsJson['incidents'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map(_parseIncident)
        .toList();

    final filteredComponents = _filterComponents(allComponents, service);
    final filteredIncidents = _filterIncidents(allIncidents, service);

    final activeIncidents = filteredIncidents.where((i) => i.isActive).toList();
    final recentIncidents = filteredIncidents
        .where((i) => i.isResolved)
        .toList();

    return ServiceSnapshot(
      service: service,
      indicator: StatusIndicator.fromPageIndicator(indicatorRaw),
      indicatorDescription: indicatorDescription,
      components: filteredComponents,
      allComponents: filteredComponents,
      activeIncidents: activeIncidents,
      recentIncidents: recentIncidents,
      fetchedAt: DateTime.now(),
      error: null,
    );
  }

  static Component _parseComponent(Map<String, dynamic> json) {
    return Component(
      id: json['id'] as String,
      name: _cleanName(json['name'] as String?),
      description: json['description'] as String?,
      status: StatusIndicator.fromComponentStatus(json['status'] as String?),
    );
  }

  static final _parenRegex = RegExp(r'\s*\([^)]*\)');

  static String _cleanName(String? raw) {
    if (raw == null || raw.isEmpty) return 'Unknown';
    final cleaned = raw.replaceAll(_parenRegex, '').trim();
    return cleaned.isEmpty ? raw : cleaned;
  }

  static Incident _parseIncident(Map<String, dynamic> json) {
    final updates = ((json['incident_updates'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map(
          (u) => IncidentUpdate(
            id: u['id'] as String? ?? '',
            status: u['status'] as String? ?? '',
            body: u['body'] as String? ?? '',
            createdAt: _parseDate(u['created_at']) ?? DateTime.now(),
          ),
        )
        .toList();

    final components = ((json['components'] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map((c) => c['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    return Incident(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Incident',
      status: json['status'] as String? ?? 'unknown',
      impact: StatusIndicator.fromIncidentImpact(json['impact'] as String?),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      resolvedAt: _parseDate(json['resolved_at']),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      shortlink: json['shortlink'] as String? ?? '',
      affectedComponentNames: components,
      updates: updates,
    );
  }

  static List<Component> _filterComponents(
    List<Component> all,
    MonitoredService service,
  ) {
    final filter = service.componentFilter;
    if (filter == null) return all;
    return all
        .where((c) => c.name.toLowerCase() == filter.toLowerCase())
        .toList();
  }

  static List<Incident> _filterIncidents(
    List<Incident> all,
    MonitoredService service,
  ) {
    final filter = service.componentFilter;
    if (filter == null) return all;
    final needle = filter.toLowerCase();
    return all
        .where(
          (i) => i.affectedComponentNames.any(
            (n) => n.toLowerCase().contains(needle),
          ),
        )
        .toList();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
