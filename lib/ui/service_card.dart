import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/service_snapshot.dart';
import 'incident_tile.dart';
import 'status_dot.dart';
import 'tokens.dart';
import 'widgets/divider.dart';
import 'widgets/glass_panel.dart';
import 'widgets/pressable.dart';
import 'widgets/pulse_glow.dart';

class ServiceCard extends StatelessWidget {
  final ServiceSnapshot snapshot;

  const ServiceCard({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final indicator = snapshot.effectiveIndicator;
    final issue = isIssue(indicator);
    final color = colorFor(indicator);

    final content = GlassPanel(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.zero,
      radius: AppRadii.md,
      glow: issue ? color : null,
      glowStrength: 0.35,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pressable(
            showHighlight: true,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.md),
            ),
            onTap: () => launchUrl(
              Uri.parse(snapshot.service.publicUrl),
              mode: LaunchMode.externalApplication,
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                StatusDot(indicator: indicator, size: 11),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    snapshot.service.name,
                    style: AppText.title.copyWith(fontSize: 13),
                  ),
                ),
                Text(
                  snapshot.error != null ? 'Offline' : indicator.label,
                  style: AppText.bodyDim,
                ),
              ],
            ),
          ),
          if (snapshot.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                'Could not reach status API.',
                style: AppText.bodyDim,
              ),
            )
          else ...[
            const ThinDivider(leftInset: 12, rightInset: 12),
            ...snapshot.components.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    StatusDot(indicator: c.status, size: 7),
                    const SizedBox(width: 9),
                    Expanded(child: Text(c.name, style: AppText.body)),
                    Text(c.status.label, style: AppText.bodyDim),
                  ],
                ),
              ),
            ),
            if (snapshot.activeIncidents.isNotEmpty) ...[
              const ThinDivider(leftInset: 12, rightInset: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                child: Text('ACTIVE INCIDENTS', style: AppText.tag),
              ),
              ...snapshot.activeIncidents.map((i) => IncidentTile(incident: i)),
            ],
            const SizedBox(height: 6),
          ],
        ],
      ),
    );

    return PulseGlow(
      enabled: issue,
      color: color,
      radius: AppRadii.md,
      child: content,
    );
  }
}
