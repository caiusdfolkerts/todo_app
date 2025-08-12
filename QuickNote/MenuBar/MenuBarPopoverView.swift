import SwiftUI
import CoreData

struct MenuBarPopoverView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)], predicate: nil, animation: .default)
    private var notes: FetchedResults<Note>
    @State private var search = ""

    var body: some View {
        VStack(spacing: 8) {
            TextField("Search", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding([.top, .horizontal])

            List(filteredNotes) { note in
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(note.displayTitle).font(.headline).lineLimit(1)
                        if let body = note.body, !body.isEmpty {
                            Text(body).lineLimit(1).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    if note.pinned { Image(systemName: "pin.fill").foregroundStyle(.secondary) }
                    Text(note.updatedAt, style: .relative).foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
                .onTapGesture { openMain(for: note) }
                .contextMenu {
                    Button(note.pinned ? "Unpin" : "Pin") { togglePin(note) }
                    Button(note.archived ? "Unarchive" : "Archive") { toggleArchive(note) }
                    Button("Delete", role: .destructive) { delete(note) }
                }
            }
            .listStyle(.inset)

            HStack {
                Button("New (⌘N)") { QuickPanelWindowController.shared.show() }
                Spacer()
            }
            .padding([.horizontal, .bottom])
        }
        .frame(minWidth: 320, minHeight: 300)
    }

    private var filteredNotes: [Note] {
        if search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return Array(notes) }
        let s = search.lowercased()
        return notes.filter { n in
            (n.title ?? "").lowercased().contains(s) || (n.body ?? "").lowercased().contains(s)
        }
    }

    private func openMain(for note: Note) {
        NSApp.activate(ignoringOtherApps: true)
    }
    private func togglePin(_ note: Note) { note.pinned.toggle(); note.updatedAt = Date(); PersistenceController.shared.save(context: context) }
    private func toggleArchive(_ note: Note) { note.archived.toggle(); note.updatedAt = Date(); PersistenceController.shared.save(context: context) }
    private func delete(_ note: Note) { context.delete(note); PersistenceController.shared.save(context: context) }
}
