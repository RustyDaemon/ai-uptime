class MonitoredService {
  final String id;
  final String name;
  final String baseUrl;
  final String? componentFilter;

  const MonitoredService({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.componentFilter,
  });

  String get summaryUrl => '$baseUrl/api/v2/summary.json';
  String get incidentsUrl => '$baseUrl/api/v2/incidents.json';
  String get publicUrl => baseUrl;
}
