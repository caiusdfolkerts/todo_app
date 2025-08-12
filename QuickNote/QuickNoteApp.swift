import SwiftUI
import CoreData

@main
struct QuickNoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup("Notes") {
            MainAppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appDelegate.quickPanelSession)
        }

        Settings {
            PreferencesView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appDelegate.quickPanelSession)
        }
    }
}
