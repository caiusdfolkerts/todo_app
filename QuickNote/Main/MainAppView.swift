import SwiftUI
import CoreData

struct MainAppView: View {
    @Environment(\.managedObjectContext) private var context

    @State private var selection: SidebarFilter = .all
    @State private var selectedNote: Note?
    @State private var query: String = ""

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } content: {
            NotesListView(selection: $selection, query: $query, selectedNote: $selectedNote)
        } detail: {
            if let note = selectedNote {
                NoteEditorView(note: note)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("Select or create a note").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: newNote) { Image(systemName: "square.and.pencil") }
                    .keyboardShortcut("n", modifiers: [.command])
            }
            ToolbarItem { TextField("Search", text: $query).textFieldStyle(.roundedBorder) }
        }
    }

    private func newNote() {
        let note = Note.new(in: context)
        PersistenceController.shared.save(context: context)
        selectedNote = note
    }
}

enum SidebarFilter: Hashable { case all, today, pinned, archived }

struct NotesListView: View {
    @Environment(\.managedObjectContext) private var context
    @Binding var selection: SidebarFilter
    @Binding var query: String
    @Binding var selectedNote: Note?

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)], predicate: nil, animation: .default)
    private var allNotes: FetchedResults<Note>

    var body: some View {
        let filtered = filteredNotes
        List(filtered, selection: $selectedNote) { note in
            HStack {
                VStack(alignment: .leading) {
                    Text(note.displayTitle).font(.headline)
                    if let body = note.body, !body.isEmpty { Text(body).lineLimit(1).foregroundStyle(.secondary) }
                }
                Spacer()
                if note.pinned { Image(systemName: "pin.fill").foregroundStyle(.secondary) }
                Text(note.updatedAt, style: .time).foregroundStyle(.tertiary)
            }
            .contextMenu {
                Button(note.pinned ? "Unpin" : "Pin") { note.pinned.toggle(); save() }
                Button(note.archived ? "Unarchive" : "Archive") { note.archived.toggle(); save() }
                Button("Delete", role: .destructive) { context.delete(note); save() }
            }
        }
        .listStyle(.inset)
    }

    private var filteredNotes: [Note] {
        var notes = allNotes.filter { note in
            switch selection {
            case .all: return !note.archived
            case .today: return Calendar.current.isDateInToday(note.updatedAt) && !note.archived
            case .pinned: return note.pinned && !note.archived
            case .archived: return note.archived
            }
        }
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            notes = notes.filter { n in (n.title ?? "").lowercased().contains(q) || (n.body ?? "").lowercased().contains(q) }
        }
        return notes
    }

    private func save() { PersistenceController.shared.save(context: context) }
}
