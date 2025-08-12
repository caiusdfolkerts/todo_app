import SwiftUI
import AppKit
import Carbon

struct ShortcutRecorderView: NSViewRepresentable {
    final class RecorderView: NSView {
        var onCapture: ((Int, Int) -> Void)?
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            let keyCode = Int(event.keyCode)
            let mods = event.modifierFlags.intersection([.command, .option, .shift, .control])
            let carbonMods = (mods.contains(.command) ? Int(cmdKey) : 0)
                | (mods.contains(.option) ? Int(optionKey) : 0)
                | (mods.contains(.shift) ? Int(shiftKey) : 0)
                | (mods.contains(.control) ? Int(controlKey) : 0)
            onCapture?(keyCode, carbonMods)
        }

        override func viewDidMoveToWindow() {
            window?.makeFirstResponder(self)
        }
    }

    var onCapture: (Shortcut) -> Void

    func makeNSView(context: Context) -> RecorderView {
        let v = RecorderView(frame: .zero)
        v.onCapture = { key, mods in
            onCapture(Shortcut(keyCode: key, modifiers: mods))
        }
        return v
    }

    func updateNSView(_ nsView: RecorderView, context: Context) {}
}
