import SwiftUI
import AppKit
import Carbon
import CoreData

final class AppDelegate: NSObject, NSApplicationDelegate {
    let persistenceController = PersistenceController.shared
    var statusBarController: StatusBarController!
    let quickPanel = QuickPanelWindowController.shared
    let quickPanelSession = QuickPanelSession()

    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyEventHandler: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Prepare Core Data context
        let context = persistenceController.container.viewContext
        context.automaticallyMergesChangesFromParent = true

        // Status bar
        statusBarController = StatusBarController(
            persistenceController: persistenceController,
            quickPanel: quickPanel
        )

        // Global hotkey
        registerGlobalHotkey(from: UserDefaultsHotkeyStorage.shared.currentHotkey())

        // Initial panel configuration
        quickPanel.configureIfNeeded(context: context, session: quickPanelSession)
    }

    func applicationWillTerminate(_ notification: Notification) {
        unregisterGlobalHotkey()
    }

    func registerGlobalHotkey(from shortcut: Shortcut) {
        unregisterGlobalHotkey()

        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let status = InstallEventHandler(GetEventDispatcherTarget(), { (handlerCallRef, eventRef, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(eventRef, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            if hotKeyID.id == UInt32(1) {
                DispatchQueue.main.async {
                    QuickPanelWindowController.shared.toggle()
                }
            }
            return noErr
        }, 1, &eventSpec, nil, &hotKeyEventHandler)
        if status != noErr {
            NSLog("Failed to install hotkey handler: \(status)")
        }

        var hotKeyID = EventHotKeyID(signature: OSType(0x514E5445), id: UInt32(1)) // 'QNTE'
        let reg = RegisterEventHotKey(UInt32(shortcut.keyCode), UInt32(shortcut.modifiers), hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
        if reg != noErr {
            NSLog("Failed to register hotkey: \(reg)")
        }
    }

    func unregisterGlobalHotkey() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let handler = hotKeyEventHandler {
            RemoveEventHandler(handler)
            hotKeyEventHandler = nil
        }
    }
}
