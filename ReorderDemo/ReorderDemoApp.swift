//
//  ReorderDemoApp.swift
//  ReorderDemo
//
//  Created by Will on 2/13/24.
//

import CoreData
import SwiftUI

@main
struct ReorderDemo: App {
    @StateObject private var seeder = Seeder()
    let persistenceController = PersistenceController.shared
    let userDefaults = UserDefaults.standard
    let userDefaultsKey = "hasSeededWithSampleData"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(seeder)
                .onAppear {
                    if !userDefaults.bool(forKey: userDefaultsKey) {
                        seeder.seedWithSampleData(userDefaults: userDefaults, userDefaultsKey: userDefaultsKey)
                    }
                }
        }
    }
}
