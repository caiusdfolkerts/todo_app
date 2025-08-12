import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var session: QuickPanelSession

    @State private var currentShortcut: Shortcut = UserDefaultsHotkeyStorage.shared.currentHotkey()

    var body: some View {
        Form {
            Section("Global Hotkey") {
                HStack {
                    Text(shortcutDescription(currentShortcut)).frame(width: 160, alignment: .leading)
                    ShortcutRecorderView { shortcut in
                        currentShortcut = shortcut
                        UserDefaultsHotkeyStorage.shared.save(shortcut)
                        if let delegate = NSApp.delegate as? AppDelegate { delegate.registerGlobalHotkey(from: shortcut) }
                    }
                    .frame(width: 220, height: 28)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
                    .background(.thinMaterial)
                }
                Text("Default is ⌘⏎").foregroundStyle(.secondary).font(.footnote)
            }

            Section("Quick Panel") {
                Toggle("Remember last size", isOn: .constant(true))
                Text("Position: top-right of active screen with 16pt inset.")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }

            Section("Sync") {
                Toggle("Cloud sync via iCloud (placeholder)", isOn: .constant(false))
            }
        }
        .padding(20)
        .frame(width: 520)
    }

    private func shortcutDescription(_ s: Shortcut) -> String {
        var parts: [String] = []
        if (s.modifiers & Int(cmdKey)) != 0 { parts.append("⌘") }
        if (s.modifiers & Int(shiftKey)) != 0 { parts.append("⇧") }
        if (s.modifiers & Int(optionKey)) != 0 { parts.append("⌥") }
        if (s.modifiers & Int(controlKey)) != 0 { parts.append("⌃") }
        let key = KeyCodes.keyName(for: s.keyCode)
        parts.append(key)
        return parts.joined()
    }
}
