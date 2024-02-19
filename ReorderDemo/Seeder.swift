//
//  Seeder.swift
//  ReorderDemo
//
//  Created by Will on 2/19/24.
//

import Foundation

class Seeder: ObservableObject {
    @Published var progress: Double = 0
    @Published var isSeeding: Bool = false

    let persistenceController = PersistenceController.shared

    func seedWithSampleData(userDefaults: UserDefaults, userDefaultsKey: String) {
        print("Seeding...")
        print("creating 100,000 records...")

        let backgroundContext = persistenceController.container.newBackgroundContext()

        // Assume the seeding process is initiated here
        DispatchQueue.global(qos: .background).async {
            backgroundContext.perform {
                // Ensure all CoreData operations are performed within this block

                // Update progress and isSeeding on the main thread
                // Make sure to adjust the progress calculation as needed
                for number in 1...100_000 {

                    DispatchQueue.main.async {
                        self.progress = Double(number) / 100_000
                        self.isSeeding = true
                    }

                    let newItem = Item(context: backgroundContext)
                    newItem.name = "\(number)"

                    // Uses sparce indexing.  1000, 2000, 3000... instead of 0,1,2,3...
                    newItem.orderIndex = Int64(number * 1000)

                    // Periodically save and reset the context to release memory
                    if number % 1_000 == 0 { // Adjust batch size as appropriate
                        do {
                            DispatchQueue.main.async {
                                self.progress = Double(number) / 100_000
                            }

                            try backgroundContext.save()
                            backgroundContext.reset() // Reset the context to free up memory
                        } catch {
                            // Handle save error
                            print("Background context save error: \(error)")
                        }
                    }
                }

                print("saving 100,000 records...")

                DispatchQueue.main.async {
                    self.isSeeding = false
                    userDefaults.setValue(true, forKey: userDefaultsKey)
                }

                print("Done seeding.")
            }
        }
    }
}
