import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'config.dart';
import 'state/providers.dart';
import 'ui/popover_shell.dart';
import 'ui/widgets/app_root.dart';

const _popoverSize = Size(380, 520);
const _popoverChannel = MethodChannel(popoverChannelName);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  final options = WindowOptions(
    size: _popoverSize,
    center: false,
    skipTaskbar: true,
    title: appTitle,
    titleBarStyle: Platform.isMacOS
        ? TitleBarStyle.hidden
        : TitleBarStyle.normal,
    backgroundColor: const Color(0x00000000),
    alwaysOnTop: true,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setAsFrameless();
    if (Platform.isMacOS) {
      await windowManager.setHasShadow(true);
    }
    await windowManager.setResizable(false);
  });

  runApp(const ProviderScope(child: _App()));
}

class _App extends ConsumerStatefulWidget {
  const _App();

  @override
  ConsumerState<_App> createState() => _AppState();
}

class _AppState extends ConsumerState<_App> with TrayListener, WindowListener {
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    await ref.read(appStatusControllerProvider.notifier).start();

    // The NIB loader forces an initial window display on launch (that's how
    // Flutter gets its first frame so this bootstrap can run). The Swift side
    // kept the window fully transparent and pass-through so nothing flashed;
    // now that the first frame is behind us, fully orderOut the window so it
    // only reappears when the user clicks the tray icon.
    await windowManager.hide();
  }

  @override
  void onTrayIconMouseDown() async {
    await _togglePopover();
  }

  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'open':
        await _showPopover();
        break;
      case 'refresh':
        await ref.read(appStatusControllerProvider.notifier).refreshNow();
        break;
      case 'quit':
        if (Platform.isMacOS) {
          await windowManager.destroy();
        }
        exit(0);
    }
  }

  Future<void> _togglePopover() async {
    if (await windowManager.isVisible()) {
      await _hidePopover();
    } else {
      await _showPopover();
    }
  }

  Future<void> _showPopover() async {
    if (Platform.isMacOS) {
      // macOS: the Swift bridge positions the popover precisely under the
      // tray icon in absolute Cocoa coordinates, which avoids the
      // NSScreen.main vs screens[0] mismatch between tray_manager and
      // window_manager on multi-display setups.
      await _popoverChannel.invokeMethod('showUnderTrayIcon', {
        'width': _popoverSize.width,
        'height': _popoverSize.height,
      });
      return;
    }
    // Linux: system tray icon position is not exposed to the app via
    // AppIndicator, so pin the popover to the top-right of the primary
    // display, which is where most desktops render the tray.
    await windowManager.setAlignment(Alignment.topRight);
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _hidePopover() async {
    if (Platform.isMacOS) {
      await _popoverChannel.invokeMethod('hidePopover');
      return;
    }
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return const AppRoot(child: PopoverShell());
  }
}
