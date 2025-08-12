import SwiftUI
import CoreData

struct NoteEditorView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var note: Note
    @State private var pendingSaveWork: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 8) {
            TextField("Title", text: Binding(
                get: { note.title ?? "" },
                set: { note.title = $0; note.updatedAt = Date(); debouncedSave() }
            ))
            .font(.title2)
            .textFieldStyle(.plain)

            TextEditor(text: Binding(
                get: { note.body ?? "" },
                set: { note.body = $0; note.updatedAt = Date(); debouncedSave() }
            ))
            .font(.body)
            .lineSpacing(4)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button { note.pinned.toggle(); saveNow() } label: { Image(systemName: note.pinned ? "pin.fill" : "pin") }
                Button { note.archived.toggle(); saveNow() } label: { Image(systemName: note.archived ? "tray.and.arrow.down.fill" : "tray.and.arrow.down") }
                Button(role: .destructive) { context.delete(note); saveNow() } label: { Image(systemName: "trash") }
                Spacer()
                Text(note.updatedAt.formatted())
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        }
    }

    private func debouncedSave() {
        pendingSaveWork?.cancel()
        let work = DispatchWorkItem { saveNow() }
        pendingSaveWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }

    private func saveNow() { PersistenceController.shared.save(context: context) }
}
