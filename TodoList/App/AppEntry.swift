import SwiftUI
import SwiftData

@main
struct TodoListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .modelContainer(PersistenceController.sharedModelContainer)
    }
}
