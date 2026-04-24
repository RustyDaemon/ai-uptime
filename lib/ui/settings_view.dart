import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config.dart';
import '../models/component.dart';
import '../models/service.dart';
import '../models/service_snapshot.dart';
import '../state/providers.dart';
import 'status_dot.dart';
import 'tokens.dart';
import 'widgets/app_dropdown.dart';
import 'widgets/app_switch.dart';
import 'widgets/divider.dart';
import 'widgets/glass_panel.dart';
import 'widgets/icon_glyph.dart';
import 'widgets/pressable.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final snapshot = ref.watch(snapshotProvider);
    final controller = ref.read(settingsProvider.notifier);
    final appStatusController = ref.read(appStatusControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      children: [
        _sectionLabel('Appearance'),
        GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text('Theme', style: AppText.body)),
                    AppDropdown<AppThemeMode>(
                      value: settings.themeMode,
                      items: [
                        for (final m in AppThemeMode.values)
                          AppDropdownItem(value: m, label: m.label),
                      ],
                      onChanged: controller.setThemeMode,
                    ),
                  ],
                ),
              ),
              const ThinDivider(leftInset: 12, rightInset: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text('Text size', style: AppText.body)),
                    AppDropdown<AppTextScale>(
                      value: settings.textScale,
                      items: [
                        for (final s in AppTextScale.values)
                          AppDropdownItem(value: s, label: s.label),
                      ],
                      onChanged: controller.setTextScale,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _sectionLabel('Polling'),
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text('Refresh interval', style: AppText.body)),
              AppDropdown<int>(
                value: settings.pollIntervalSeconds,
                items: [
                  for (final v in pollIntervalChoices)
                    AppDropdownItem(value: v, label: _formatInterval(v)),
                ],
                onChanged: controller.setPollInterval,
              ),
            ],
          ),
        ),
        _sectionLabel('GitHub region'),
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text('Status page', style: AppText.body)),
              AppDropdown<GitHubRegion>(
                value: settings.githubRegion,
                items: [
                  for (final r in GitHubRegion.values)
                    AppDropdownItem(value: r, label: r.label),
                ],
                onChanged: controller.setGitHubRegion,
              ),
            ],
          ),
        ),
        _sectionLabel('Services to show'),
        for (final svc in monitoredServices(settings.githubRegion))
          _ProviderPicker(
            service: svc,
            snapshot: _snapshotFor(snapshot.services, svc.id),
            hiddenIds: settings.hiddenIdsFor(svc.id),
            expanded: _expanded.contains(svc.id),
            onToggleExpanded: () => setState(() {
              if (!_expanded.remove(svc.id)) _expanded.add(svc.id);
            }),
            onToggleComponent: (componentId, visible) =>
                controller.setComponentVisibility(svc.id, componentId, visible),
          ),
        _sectionLabel('Notifications'),
        GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _toggle(
                label: 'New incident posted',
                value: settings.notifyOnNewIncident,
                onChanged: controller.setNotifyOnNewIncident,
              ),
              const ThinDivider(leftInset: 12, rightInset: 12),
              _toggle(
                label: 'Component status changes',
                value: settings.notifyOnComponentChange,
                onChanged: controller.setNotifyOnComponentChange,
              ),
              const ThinDivider(leftInset: 12, rightInset: 12),
              _toggle(
                label: 'Incident resolved',
                value: settings.notifyOnResolved,
                onChanged: controller.setNotifyOnResolved,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pressable(
              onTap: () => appStatusController.refreshNow(),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              backgroundColor: AppColors.panelStrong,
              border: Border.all(color: AppColors.borderStrong),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Text('Check now', style: AppText.body),
            ),
          ],
        ),
      ],
    );
  }

  ServiceSnapshot? _snapshotFor(List<ServiceSnapshot> all, String id) {
    for (final s in all) {
      if (s.service.id == id) return s;
    }
    return null;
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
    child: Text(text.toUpperCase(), style: AppText.tag),
  );

  Widget _toggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppText.body)),
        AppSwitch(value: value, onChanged: onChanged),
      ],
    ),
  );

  String _formatInterval(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h';
  }
}

class _ProviderPicker extends StatelessWidget {
  final MonitoredService service;
  final ServiceSnapshot? snapshot;
  final Set<String> hiddenIds;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final void Function(String componentId, bool visible) onToggleComponent;

  const _ProviderPicker({
    required this.service,
    required this.snapshot,
    required this.hiddenIds,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onToggleComponent,
  });

  @override
  Widget build(BuildContext context) {
    final all = snapshot?.allComponents ?? const <Component>[];
    final total = all.length;
    final visibleCount =
        total - all.where((c) => hiddenIds.contains(c.id)).length;
    final loading = snapshot == null || (snapshot!.error == null && total == 0);
    final errored = snapshot?.error != null;

    final countText = errored
        ? 'Offline'
        : loading
        ? '—'
        : '$visibleCount / $total';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Pressable(
              onTap: (loading || errored) ? null : onToggleExpanded,
              borderRadius: BorderRadius.circular(AppRadii.md),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(child: Text(service.name, style: AppText.title)),
                  Text(countText, style: AppText.bodyDim),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: IconGlyph.chevronDown(
                      size: 12,
                      color: AppColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: !expanded
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ThinDivider(leftInset: 12, rightInset: 12),
                        if (loading)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Text(
                              errored
                                  ? 'Could not reach status API.'
                                  : 'Waiting for first fetch…',
                              style: AppText.bodyDim,
                            ),
                          )
                        else
                          ...all.map((c) {
                            final visible = !hiddenIds.contains(c.id);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  StatusDot(indicator: c.status, size: 7),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(c.name, style: AppText.body),
                                  ),
                                  AppSwitch(
                                    value: visible,
                                    onChanged: (v) =>
                                        onToggleComponent(c.id, v),
                                  ),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 4),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
