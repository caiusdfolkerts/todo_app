import Foundation
import Carbon

enum KeyCodes {
    static func keyName(for keyCode: Int) -> String {
        switch keyCode {
        case Int(kVK_Return): return "⏎"
        case Int(kVK_Escape): return "⎋"
        case Int(kVK_Tab): return "⇥"
        case Int(kVK_Space): return "Space"
        default:
            return String(keyCode)
        }
    }
}
