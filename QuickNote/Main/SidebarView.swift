import SwiftUI
import CoreData

struct SidebarView: View {
    @Environment(\.managedObjectContext) private var context
    @Binding var selection: SidebarFilter

    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "archived == NO")) private var all: FetchedResults<Note>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "pinned == YES AND archived == NO")) private var pinned: FetchedResults<Note>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "archived == YES")) private var archived: FetchedResults<Note>

    var body: some View {
        List(selection: $selection) {
            Section("Library") {
                NavigationLink(value: SidebarFilter.all) { label("All Notes", count: all.count) }
                NavigationLink(value: SidebarFilter.today) { label("Today", count: todayCount) }
                NavigationLink(value: SidebarFilter.pinned) { label("Pinned", count: pinned.count) }
                NavigationLink(value: SidebarFilter.archived) { label("Archived", count: archived.count) }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 180)
    }

    private var todayCount: Int { all.filter { Calendar.current.isDateInToday($0.updatedAt) }.count }

    private func label(_ title: String, count: Int) -> some View {
        HStack { Text(title); Spacer(); Text("\(count)").foregroundStyle(.secondary) }
    }
}
