import SwiftUI
import CoreData

struct QuickPanelView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var session: QuickPanelSession

    @State private var titleText: String = ""
    @State private var bodyText: String = ""
    @State private var showSavedTick: Bool = false
    @State private var pendingSaveWork: DispatchWorkItem?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                TextField("Title", text: $titleText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16, weight: .semibold))
                    .onChange(of: titleText) { _ in debouncedSave() }

                TextEditor(text: $bodyText)
                    .font(.system(.body, design: .monospaced))
                    .lineSpacing(4)
                    .overlay(
                        Group {
                            if titleText.isEmpty && bodyText.isEmpty {
                                Text("Type. Autosaves. ⎋ to hide.")
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    )
                    .onChange(of: bodyText) { _ in debouncedSave() }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            if showSavedTick {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .padding(10)
                    .transition(.opacity)
            }
        }
        .onAppear { loadOrCreateNote() }
        .onReceive(NotificationCenter.default.publisher(for: .quickPanelDidHide)) { _ in
            saveNow()
            flashSaved()
        }
        .onExitCommand(perform: { QuickPanelWindowController.shared.hide() })
        .frame(minWidth: 320, minHeight: 200)
    }

    private func loadOrCreateNote() {
        if let id = session.currentNoteID,
           let note = try? context.existingObject(with: id) as? Note {
            titleText = note.title ?? ""
            bodyText = note.body ?? ""
        } else {
            let note = Note.new(in: context)
            session.currentNoteID = note.objectID
            titleText = ""
            bodyText = ""
            saveNow()
        }
    }

    private func debouncedSave() {
        pendingSaveWork?.cancel()
        let work = DispatchWorkItem { saveNow() }
        pendingSaveWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }

    private func saveNow() {
        guard let id = session.currentNoteID,
              let note = try? context.existingObject(with: id) as? Note else { return }
        note.title = titleText
        note.body = bodyText
        note.updatedAt = Date()
        PersistenceController.shared.save(context: context)
    }

    private func flashSaved() {
        withAnimation(.easeInOut(duration: 0.15)) { showSavedTick = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.25)) { showSavedTick = false }
        }
    }
}
