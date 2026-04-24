import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  int _nextId = 1;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxInit = LinuxInitializationSettings(defaultActionName: 'Open');
    const init = InitializationSettings(macOS: darwinInit, linux: linuxInit);
    await _plugin.initialize(
      settings: init,
      onDidReceiveNotificationResponse: _onTap,
    );
    _initialized = true;
  }

  Future<void> _onTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    final uri = Uri.tryParse(payload);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    const darwin = DarwinNotificationDetails();
    const linux = LinuxNotificationDetails();
    const details = NotificationDetails(macOS: darwin, linux: linux);
    await _plugin.show(
      id: _nextId++,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}
