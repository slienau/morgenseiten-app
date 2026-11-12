import AppKit
import SwiftUI

@main
struct MorgenseitenApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Window("Morgenseiten", id: "main") {
            ContentView()
                .frame(minWidth: 520, minHeight: 420)
        }
        .defaultSize(width: 760, height: 820)
        .windowStyle(.hiddenTitleBar)
        .commands {
            // A single-page editor has no documents to create.
            CommandGroup(replacing: .newItem) {}
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Needed when the binary is started outside an .app bundle (`swift run`).
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
