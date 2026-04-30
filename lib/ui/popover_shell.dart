import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';

import '../config.dart';
import '../state/providers.dart';
import 'history_view.dart';
import 'now_view.dart';
import 'settings_view.dart';
import 'tokens.dart';
import 'widgets/app_icon_button.dart';
import 'widgets/glass_background.dart';
import 'widgets/icon_glyph.dart';
import 'widgets/segmented_pill.dart';

const _popoverChannel = MethodChannel(popoverChannelName);

Future<void> _hidePopover() async {
  if (Platform.isMacOS) {
    await _popoverChannel.invokeMethod('hidePopover');
    return;
  }
  await windowManager.hide();
}

class PopoverShell extends ConsumerStatefulWidget {
  const PopoverShell({super.key});

  @override
  ConsumerState<PopoverShell> createState() => _PopoverShellState();
}

class _PopoverShellState extends ConsumerState<PopoverShell> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(snapshotProvider);
    // Watch theme mode and text scale so this subtree rebuilds when the user
    // switches either. AppRoot applies the tokens, but its rebuild can't
    // propagate through const children, so PopoverShell must re-enter build()
    // itself and pick up fresh AppText.* styles.
    ref.watch(settingsProvider.select((s) => s.themeMode));
    ref.watch(settingsProvider.select((s) => s.textScale));
    final appStatusController = ref.read(appStatusControllerProvider.notifier);
    final fetchedLabel = snapshot.services.isEmpty
        ? '—'
        : DateFormat('HH:mm:ss').format(snapshot.fetchedAt.toLocal());

    return GlassBackground(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              children: [
                Text(appTitle, style: AppText.title),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'Updated $fetchedLabel',
                          style: AppText.updateTime,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppIconButton(
                        glyph: IconGlyphKind.refresh,
                        onTap: () => appStatusController.refreshNow(),
                      ),
                      if (!Platform.isLinux) ...[
                        const SizedBox(width: 2),
                        AppIconButton(
                          glyph: IconGlyphKind.close,
                          onTap: _hidePopover,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
            child: SegmentedPill<int>(
              segments: const [
                SegmentOption(value: 0, label: 'Now'),
                SegmentOption(value: 1, label: 'History'),
                SegmentOption(value: 2, label: 'Settings'),
              ],
              selected: _tabIndex,
              onChanged: (v) => setState(() => _tabIndex = v),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              // Intentionally non-const: on theme change we need the tab
              // children to be fresh widget instances so IndexedStack's
              // Element updates them instead of skipping via identity match.
              children: [NowView(), HistoryView(), SettingsView()],
            ),
          ),
        ],
      ),
    );
  }
}
