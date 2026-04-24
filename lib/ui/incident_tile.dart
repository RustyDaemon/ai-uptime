import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/incident.dart';
import 'status_dot.dart';
import 'tokens.dart';
import 'widgets/pressable.dart';

class IncidentTile extends StatelessWidget {
  final Incident incident;
  final bool compact;
  final bool detailed;

  const IncidentTile({
    super.key,
    required this.incident,
    this.compact = false,
    this.detailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final latest = incident.latestUpdate;
    final enabled = incident.shortlink.isNotEmpty;

    return Pressable(
      onTap: enabled
          ? () => launchUrl(
              Uri.parse(incident.shortlink),
              mode: LaunchMode.externalApplication,
            )
          : null,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 9),
            child: StatusDot(indicator: incident.impact, size: 9),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.name,
                  style: AppText.incidentTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(),
                  style: AppText.bodyDim.copyWith(fontSize: 10.5),
                ),
                if (detailed && incident.affectedComponentNames.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _ComponentChips(names: incident.affectedComponentNames),
                ],
                if ((detailed || !compact) && latest != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    latest.body,
                    style: AppText.incidentBody,
                    maxLines: detailed ? 4 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final dateFmt = DateFormat('MMM d, HH:mm');
    if (detailed) {
      final start = dateFmt.format(incident.createdAt.toLocal());
      if (incident.isResolved && incident.resolvedAt != null) {
        final end = dateFmt.format(incident.resolvedAt!.toLocal());
        final dur = _formatDuration(incident.createdAt, incident.resolvedAt!);
        return 'Started $start · Resolved $end · $dur';
      }
      final dur = _formatDuration(incident.createdAt, DateTime.now());
      return 'Started $start · Ongoing · $dur';
    }
    if (incident.latestUpdate != null) {
      return '${incident.status} · ${dateFmt.format(incident.updatedAt.toLocal())}';
    }
    return dateFmt.format(incident.createdAt.toLocal());
  }

  static String _formatDuration(DateTime start, DateTime end) {
    var seconds = end.difference(start).inSeconds;
    if (seconds < 0) seconds = 0;
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m';
    return '<1m';
  }
}

class _ComponentChips extends StatelessWidget {
  final List<String> names;
  const _ComponentChips({required this.names});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final n in names)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(n, style: AppText.tag),
          ),
      ],
    );
  }
}
