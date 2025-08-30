import SwiftUI
import AppKit

@main
struct PomoTrakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app doesn't appear in the Dock
        NSApp.setActivationPolicy(.accessory)
        
        setupMenuBar()
        setupData()
        
        // Show the app when clicking the menu bar item
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func setupMenuBar() {
        let contentView = ContentView()
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 500)
        popover.behavior = .transient
        popover.animates = true
        
        let hostingView = NSHostingController(rootView: contentView)
        hostingView.view.frame = NSRect(x: 0, y: 0, width: 300, height: 500)
        
        popover.contentViewController = hostingView
        self.popover = popover
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "PomoTrak")
            button.action = #selector(togglePopover(_:))
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusBarItem.button else { return }
        
        if popover.isShown {
            popover.performClose(sender)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            
            // Set focus to the popover's content view
            if let contentVC = popover.contentViewController as? NSHostingController<ContentView> {
                contentVC.view.window?.makeKey()
            }
        }
    }
    
    @MainActor
    private func setupData() {
        // Ensure DataManager is initialized
        _ = DataManager.shared
    }
}
