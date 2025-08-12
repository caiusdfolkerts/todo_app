import AppKit
import SwiftUI

final class StatusBarController {
    private let statusItem: NSStatusItem
    private let popover = NSPopover()

    private let persistenceController: PersistenceController
    private unowned let quickPanel: QuickPanelWindowController

    init(persistenceController: PersistenceController, quickPanel: QuickPanelWindowController) {
        self.persistenceController = persistenceController
        self.quickPanel = quickPanel
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Notes")
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        popover.behavior = .transient
        popover.contentSize = NSSize(width: 380, height: 420)
        popover.contentViewController = NSHostingController(rootView: MenuBarPopoverView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext))
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showMenu()
            return
        }
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit QuickNote", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func openPreferences() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }

    @objc private func quit() { NSApp.terminate(nil) }
}
