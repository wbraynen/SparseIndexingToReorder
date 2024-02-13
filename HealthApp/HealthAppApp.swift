//
//  HealthAppApp.swift
//  HealthApp
//
//  Created by Will on 2/13/24.
//

import SwiftUI

@main
struct HealthAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
