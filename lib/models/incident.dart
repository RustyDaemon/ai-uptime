import 'status_indicator.dart';

class IncidentUpdate {
  final String id;
  final String status;
  final String body;
  final DateTime createdAt;

  const IncidentUpdate({
    required this.id,
    required this.status,
    required this.body,
    required this.createdAt,
  });
}

class Incident {
  final String id;
  final String name;
  final String status;
  final StatusIndicator impact;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime updatedAt;
  final String shortlink;
  final List<String> affectedComponentNames;
  final List<IncidentUpdate> updates;

  const Incident({
    required this.id,
    required this.name,
    required this.status,
    required this.impact,
    required this.createdAt,
    required this.resolvedAt,
    required this.updatedAt,
    required this.shortlink,
    required this.affectedComponentNames,
    required this.updates,
  });

  bool get isResolved => status == 'resolved' || status == 'postmortem';
  bool get isActive => !isResolved;

  IncidentUpdate? get latestUpdate => updates.isEmpty ? null : updates.first;
}
