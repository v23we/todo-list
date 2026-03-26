import SwiftUI
import SwiftData

@main
struct TodoListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(PersistenceController.sharedModelContainer)
    }
}
