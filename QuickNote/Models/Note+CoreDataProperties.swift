import Foundation
import CoreData

extension Note {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var pinned: Bool
    @NSManaged public var archived: Bool
}

extension Note: Identifiable { }

extension Note {
    static func new(in context: NSManagedObjectContext) -> Note {
        let note = Note(context: context)
        note.id = UUID()
        note.createdAt = Date()
        note.updatedAt = Date()
        note.title = ""
        note.body = ""
        note.pinned = false
        note.archived = false
        return note
    }

    var displayTitle: String {
        if let title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return title
        }
        let firstLine = (body ?? "").split(separator: "\n").first.map(String.init) ?? ""
        return firstLine.isEmpty ? "Untitled" : firstLine
    }
}
