import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: false)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let channel = FlutterMethodChannel(
      name: "ai_uptime/popover",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "showUnderTrayIcon":
        let args = call.arguments as? [String: Any] ?? [:]
        let width = (args["width"] as? NSNumber)?.doubleValue ?? 380
        let height = (args["height"] as? NSNumber)?.doubleValue ?? 520
        self.showPopover(width: width, height: height)
        result(nil)
      case "hidePopover":
        self.orderOut(nil)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // The NIB loader will display the window once awakeFromNib returns
    // (visibleAtLaunch defaults to YES, and we need that so Flutter can
    // render a first frame and the Dart postFrameCallback fires). Make the
    // window fully transparent and pass-through for the brief interval
    // before Dart calls windowManager.hide(), so the user never sees a flash
    // at the XIB's default rect.
    self.alphaValue = 0
    self.ignoresMouseEvents = true

    super.awakeFromNib()
  }

  // Position the window directly below the tray icon's status bar window,
  // working in absolute Cocoa coordinates so multi-display setups work.
  private func showPopover(width: CGFloat, height: CGFloat) {
    let trayWindow = NSApp.windows.first { window in
      let className = NSStringFromClass(type(of: window))
      return className.contains("StatusBar") || className.contains("StatusItem")
    }
    let margin: CGFloat = 6
    var rect: NSRect
    if let tray = trayWindow {
      let trayFrame = tray.frame
      let centerX = trayFrame.origin.x + trayFrame.size.width / 2
      let topY = trayFrame.origin.y - margin
      rect = NSRect(
        x: centerX - width / 2,
        y: topY - height,
        width: width,
        height: height
      )
      // Constrain horizontally to the screen containing the tray.
      if let screen = NSScreen.screens.first(where: {
        $0.frame.contains(NSPoint(x: centerX, y: trayFrame.origin.y))
      }) {
        let screenFrame = screen.frame
        if rect.origin.x < screenFrame.origin.x + 4 {
          rect.origin.x = screenFrame.origin.x + 4
        }
        let maxX = screenFrame.origin.x + screenFrame.size.width - 4
        if rect.origin.x + rect.size.width > maxX {
          rect.origin.x = maxX - rect.size.width
        }
      }
    } else {
      // Fallback: center on the main screen.
      let screen = NSScreen.main ?? NSScreen.screens[0]
      let f = screen.frame
      rect = NSRect(
        x: f.origin.x + (f.size.width - width) / 2,
        y: f.origin.y + f.size.height - height - 40,
        width: width,
        height: height
      )
    }
    self.setFrame(rect, display: true)
    // Restore the startup dampers set in awakeFromNib so the popover is
    // actually visible and interactive.
    self.alphaValue = 1
    self.ignoresMouseEvents = false
    self.makeKeyAndOrderFront(nil)
  }
}
