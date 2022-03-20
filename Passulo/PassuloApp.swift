import SwiftUI

@main
struct PassuloApp: App {
    let persistenceController = PersistenceController.shared
    @State var keyCache = KeyCache.shared

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
            .task {
                await keyCache.loadKeys(for: URL(string: "https://app.passulo.com")!)
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
