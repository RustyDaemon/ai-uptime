import 'service_snapshot.dart';
import 'status_indicator.dart';

class AppSnapshot {
  final List<ServiceSnapshot> services;
  final DateTime fetchedAt;

  const AppSnapshot({required this.services, required this.fetchedAt});

  factory AppSnapshot.empty() => AppSnapshot(
    services: const [],
    fetchedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  StatusIndicator get worstIndicator =>
      StatusIndicator.worstOf(services.map((s) => s.effectiveIndicator));

  bool get hasError => services.any((s) => s.error != null);
}
