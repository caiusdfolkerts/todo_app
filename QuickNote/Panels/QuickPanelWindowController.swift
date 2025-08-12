import AppKit
import SwiftUI
import CoreData

final class QuickPanelSession: ObservableObject {
    @Published var currentNoteID: NSManagedObjectID?
}

final class QuickPanelWindowController: NSWindowController, NSWindowDelegate {
    static let shared = QuickPanelWindowController()

    private var hostingView: NSHostingView<QuickPanelView>?
    private var configured = false
    private var context: NSManagedObjectContext!
    private weak var session: QuickPanelSession?

    private let defaultSize = NSSize(width: 420, height: 280)

    func configureIfNeeded(context: NSManagedObjectContext, session: QuickPanelSession) {
        guard !configured else { return }
        self.context = context
        self.session = session

        let view = QuickPanelView().environment(\.managedObjectContext, context).environmentObject(session)
        let hosting = NSHostingView(rootView: view)
        hosting.translatesAutoresizingMaskIntoConstraints = false

        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: defaultSize),
                            styleMask: [.nonactivatingPanel, .borderless],
                            backing: .buffered,
                            defer: false)
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.delegate = self

        panel.contentView = hosting
        self.hostingView = hosting
        self.window = panel

        configured = true
        positionPanel(animated: false)
        window?.orderOut(nil)
    }

    func toggle() {
        guard let window else { return }
        if window.isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        guard let window else { return }
        positionPanel(animated: false)
        NSApp.activate(ignoringOtherApps: true)
        if !window.isVisible { animateIn() }
        window.makeKeyAndOrderFront(nil)
    }

    func hide() {
        guard let window else { return }
        animateOut()
        window.orderOut(nil)
        NotificationCenter.default.post(name: .quickPanelDidHide, object: nil)
    }

    func windowDidEndLiveResize(_ notification: Notification) {
        guard let size = window?.frame.size else { return }
        UserDefaults.standard.set(Double(size.width), forKey: "QuickPanelWidth")
        UserDefaults.standard.set(Double(size.height), forKey: "QuickPanelHeight")
    }

    private func positionPanel(animated: Bool) {
        guard let screen = NSScreen.main, let window else { return }
        let visible = screen.visibleFrame
        let storedSize = storedPanelSize()
        let size = NSSize(width: max(320, storedSize.width), height: max(200, storedSize.height))
        let inset: CGFloat = 16
        let origin = NSPoint(x: visible.maxX - size.width - inset, y: visible.maxY - size.height - inset)
        var frame = NSRect(origin: origin, size: size)
        if animated {
            window.animator().setFrame(frame, display: false)
        } else {
            window.setFrame(frame, display: false)
        }
    }

    private func animateIn() {
        guard let window else { return }
        positionPanel(animated: false)
        var frame = window.frame
        frame.origin.x += 24
        window.setFrame(frame, display: false)
        window.alphaValue = 0.0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.12
            var final = window.frame
            final.origin.x -= 24
            window.animator().setFrame(final, display: true)
            window.animator().alphaValue = 1.0
        }
    }

    private func animateOut() {
        guard let window else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.08
            var off = window.frame
            off.origin.x += 24
            window.animator().setFrame(off, display: true)
            window.animator().alphaValue = 0.0
        } completionHandler: {
            window.alphaValue = 1.0
            self.positionPanel(animated: false)
        }
    }

    private func storedPanelSize() -> NSSize {
        let w = UserDefaults.standard.double(forKey: "QuickPanelWidth")
        let h = UserDefaults.standard.double(forKey: "QuickPanelHeight")
        if w > 0, h > 0 { return NSSize(width: w, height: h) }
        return defaultSize
    }
}

extension Notification.Name {
    static let quickPanelDidHide = Notification.Name("QuickPanelDidHide")
}
