import Foundation
import Carbon

struct Shortcut: Equatable, Codable {
    var keyCode: Int
    var modifiers: Int

    static let `default` = Shortcut(keyCode: Int(kVK_Return), modifiers: Int(cmdKey))
}

final class UserDefaultsHotkeyStorage {
    static let shared = UserDefaultsHotkeyStorage()
    private let key = "QuickNoteHotkey"

    func currentHotkey() -> Shortcut {
        if let data = UserDefaults.standard.data(forKey: key),
           let s = try? JSONDecoder().decode(Shortcut.self, from: data) {
            return s
        }
        return .default
    }

    func save(_ shortcut: Shortcut) {
        if let data = try? JSONEncoder().encode(shortcut) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
