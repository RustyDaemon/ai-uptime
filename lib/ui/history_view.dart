import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/incident.dart';
import '../state/providers.dart';
import 'incident_tile.dart';
import 'tokens.dart';
import 'widgets/divider.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(snapshotProvider);
    if (snapshot.services.isEmpty) {
      return _center('Loading…');
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    // Window: today and the previous 6 days (7 days total).
    final windowStart = today.subtract(const Duration(days: 6));

    final items = <_HistoryItem>[];
    for (final s in snapshot.services) {
      for (final i in s.recentIncidents) {
        final local = i.updatedAt.toLocal();
        final day = DateTime(local.year, local.month, local.day);
        if (day.isBefore(windowStart)) continue;
        items.add(_HistoryItem(serviceName: s.service.name, incident: i));
      }
    }
    items.sort((a, b) => b.incident.updatedAt.compareTo(a.incident.updatedAt));

    if (items.isEmpty) {
      return _center('No incidents in the last 7 days.');
    }

    final grouped = _groupByDay(items);
    final dayFmt = DateFormat('EEEE, MMM d');

    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      final day = entry.key;
      final label = day == today
          ? 'Today'
          : day == yesterday
          ? 'Yesterday'
          : dayFmt.format(day);
      widgets.add(_SectionHeader(label: label));
      for (var i = 0; i < entry.value.length; i++) {
        final item = entry.value[i];
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 12, 0),
            child: Text(item.serviceName, style: AppText.tag),
          ),
        );
        widgets.add(IncidentTile(incident: item.incident, detailed: true));
        if (i != entry.value.length - 1) {
          widgets.add(const ThinDivider(leftInset: 16, rightInset: 16));
        }
      }
      widgets.add(const SizedBox(height: 8));
    }

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      children: widgets,
    );
  }

  Map<DateTime, List<_HistoryItem>> _groupByDay(List<_HistoryItem> items) {
    final out = <DateTime, List<_HistoryItem>>{};
    for (final item in items) {
      final local = item.incident.updatedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      out.putIfAbsent(day, () => []).add(item);
    }
    return out;
  }

  Widget _center(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, style: AppText.bodyDim),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(label.toUpperCase(), style: AppText.tag),
    );
  }
}

class _HistoryItem {
  final String serviceName;
  final Incident incident;
  _HistoryItem({required this.serviceName, required this.incident});
}
