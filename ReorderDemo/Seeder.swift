//
//  Seeder.swift
//  ReorderDemo
//
//  Created by Will on 2/19/24.
//

import CoreData
import Foundation

class Seeder: ObservableObject {
    // MARK: - Properties

    // Progress
    @Published var progress: Double = 0
    @Published var isSeeding: Bool = false

    // User Defaults
    private let userDefaults: UserDefaults
    private let userDefaultsKey: String

    // Core Data
    private let persistentContainer: NSPersistentContainer
    private let totalRecords = 100_000
    private let batchSize = 1_000

    // MARK: - Initializer

    init(
        persistentContainer: NSPersistentContainer = PersistenceController.shared.container,
        userDefaults: UserDefaults,
        userDefaultsKey: String)
    {
        self.persistentContainer = persistentContainer
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
    }

    // MARK: - Methods

    func seedWithSampleData() {
        print("Seeding...")

        isSeeding = true

        DispatchQueue.global(qos: .background).async {
            self.seedDataUsingBackgroundContext()
        }
    }

    // MARK: - Helpers

    private func seedDataUsingBackgroundContext() {
        let context = persistentContainer.newBackgroundContext()

        context.perform {
            for number in 1...self.totalRecords {
                self.createRecord(number: number, inContext: context)

                if number % self.batchSize == 0 {
                    self.updateProgress(number: number)
                    self.saveContext(context)
                }
            }

            self.saveContext(context) // Final save for any remaining records
            self.finalizeSeeding()
        }
    }

    private func createRecord(number: Int, inContext context: NSManagedObjectContext) {
        let newItem = Item(context: context)
        newItem.name = "\(number)"
        newItem.orderIndex = Int64(number * 1000) // Sparse indexing
    }

    private func updateProgress(number: Int) {
        DispatchQueue.main.async {
            self.progress = Double(number) / Double(self.totalRecords)
        }
    }

    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            context.reset() // Free up memory
        } catch {
            print("Background context save error: \(error)")
        }
    }

    private func finalizeSeeding() {
        DispatchQueue.main.async {
            self.isSeeding = false
            self.userDefaults.setValue(true, forKey: self.userDefaultsKey)
            print("Done seeding.")
        }
    }
}
