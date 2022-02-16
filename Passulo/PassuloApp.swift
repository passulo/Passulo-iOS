//
//  PassuloApp.swift
//  Passulo
//
//  Created by Jannik Arndt on 16.02.22.
//

import SwiftUI

@main
struct PassuloApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
