import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

import '../config.dart';
import '../models/app_snapshot.dart';
import '../models/status_indicator.dart';

class TrayService {
  StatusIndicator? _lastIndicator;

  Future<void> init() async {
    await trayManager.setIcon(_assetFor(StatusIndicator.unknown));
    await _setToolTip('Loading…');
    await _installMenu();
  }

  Future<void> update(AppSnapshot snapshot) async {
    final indicator = snapshot.services.isEmpty
        ? StatusIndicator.unknown
        : snapshot.worstIndicator;
    if (indicator != _lastIndicator) {
      await trayManager.setIcon(_assetFor(indicator));
      _lastIndicator = indicator;
    }
    await _setToolTip(_tooltipFor(snapshot));
  }

  // AppIndicator on Linux has no tooltip concept, so tray_manager throws
  // MissingPluginException for setToolTip there. Swallow it on Linux.
  Future<void> _setToolTip(String value) async {
    if (Platform.isLinux) return;
    await trayManager.setToolTip(value);
  }

  Future<void> _installMenu() async {
    final menu = Menu(
      items: [
        MenuItem(key: 'open', label: 'Show status'),
        MenuItem(key: 'refresh', label: 'Check now'),
        MenuItem.separator(),
        MenuItem(key: 'quit', label: 'Quit $appTitle'),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  String _assetFor(StatusIndicator s) => 'assets/tray/${s.trayAssetKey}.png';

  String _tooltipFor(AppSnapshot snapshot) {
    if (snapshot.services.isEmpty) return 'Loading…';
    final parts = <String>[];
    for (final s in snapshot.services) {
      if (s.error != null) {
        parts.add('${s.service.name}: offline');
      } else {
        parts.add('${s.service.name}: ${s.effectiveIndicator.label}');
      }
    }
    return parts.join('  ·  ');
  }
}
