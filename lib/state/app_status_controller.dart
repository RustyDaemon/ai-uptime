import 'package:flutter_riverpod/legacy.dart';

import '../models/app_snapshot.dart';
import '../services/notification_service.dart';
import '../services/poller.dart';
import '../services/settings_store.dart';
import '../services/snapshot_diff_notifier.dart';
import '../services/tray_service.dart';

class AppStatusController extends StateNotifier<AppSnapshot> {
  final Poller _poller;
  final NotificationService _notificationService;
  final TrayService _trayService;
  final SnapshotDiffNotifier _snapshotDiffNotifier;
  final AppSettings Function() _readSettings;

  bool _started = false;
  bool _hasSnapshot = false;

  AppStatusController({
    required Poller poller,
    required NotificationService notificationService,
    required TrayService trayService,
    required SnapshotDiffNotifier snapshotDiffNotifier,
    required AppSettings Function() readSettings,
  }) : _poller = poller,
       _notificationService = notificationService,
       _trayService = trayService,
       _snapshotDiffNotifier = snapshotDiffNotifier,
       _readSettings = readSettings,
       super(AppSnapshot.empty()) {
    _poller.addListener(_onSnapshot);
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _notificationService.init();
    await _trayService.init();
    await _poller.start();
  }

  Future<void> refreshNow() => _poller.refreshNow();

  Future<void> _onSnapshot(AppSnapshot next) async {
    final previous = _hasSnapshot ? state : null;
    state = next;
    _hasSnapshot = true;

    await _trayService.update(next);
    await _snapshotDiffNotifier.processTransition(
      previous: previous,
      next: next,
      settings: _readSettings(),
    );
  }

  @override
  void dispose() {
    _poller.removeListener(_onSnapshot);
    super.dispose();
  }
}
