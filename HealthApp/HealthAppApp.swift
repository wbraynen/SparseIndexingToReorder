//
//  HealthAppApp.swift
//  HealthApp
//
//  Created by Will on 2/13/24.
//

import CoreData
import SwiftUI

@main
struct HealthApp: App {
    let persistenceController = PersistenceController.shared

    let userDefaults = UserDefaults.standard
    let userDefaultsKey = "hasSeededWithSampleData"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    init() {
        let isColdLaunch = !userDefaults.bool(forKey: userDefaultsKey)

        if isColdLaunch {
            seedWithSampleData()
        }
    }

    private func seedWithSampleData() {
        let context: NSManagedObjectContext = persistenceController.container.viewContext

        for number in 1...100000 {
            let newItem = Item(context: context)
            newItem.name = "\(number)"

            // Uses sparce indexing.  1000, 2000, 3000... instead of 0,1,2,3...
            newItem.orderIndex = Int64(number * 1000)
        }

        do {
            try context.save()
            userDefaults.setValue(true, forKey: userDefaultsKey)
        } catch {
            // Handle errors, e.g., show an error message or log the error
            print("Failed to seed sample data: \(error)")
        }
    }
}
