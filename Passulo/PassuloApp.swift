import SwiftUI

@main
struct PassuloApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                ScanTab()
                    .tabItem {
                        Label("Scan", systemImage: "camera")
                    }

                HistoryTab()
                    .tabItem {
                        Label("Verlauf", systemImage: "list.dash")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
