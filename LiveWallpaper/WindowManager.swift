import Cocoa
import SwiftUI

class WindowManager: NSWindowController, NSWindowDelegate {
    static var shared: WindowManager?
    
    convenience init() {
        let contentView = NSHostingView(rootView: ContentView()) // Your SwiftUI view
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: AppConstant.windowWidth, height: AppConstant.windowHeight),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.contentView = contentView
        self.init(window: window)
        window.delegate = self
        window.center()
    }
    
    static func showWindow() {
        if let existingWindow = shared?.window {
            existingWindow.makeKeyAndOrderFront(nil) // Bring existing window to front
        } else {
            shared = WindowManager()
            shared?.window?.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func windowWillClose(_ notification: Notification) {
        Self.shared = nil
    }
}
