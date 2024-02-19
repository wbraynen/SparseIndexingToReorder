//
//  ContentView.swift
//  ReorderDemo
//
//  Created by Will on 2/13/24.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var seeder: Seeder

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.orderIndex, ascending: true)],
        animation: .default)
    var items: FetchedResults<Item>

    var body: some View {
        VStack {
            if seeder.isSeeding {
                let progress = Int(seeder.progress * 100)

                ProgressView(value: seeder.progress) {
                    Text("Seeding the database: \(progress)%")
                }
                .progressViewStyle(.circular)
            } else {
                NavigationView {
                    List {
                        ForEach(items.indices, id: \.self) { index in
                            Text(items[index].name ?? "Unknown")
                        }
                        .onMove(perform: moveItems)
                    }
                }
            }
        }
    }

    /// Uses sparce indexing.
    ///
    /// This avoids having to copy the entire dataset into memory and saving the whole thing back.
    /// However, this way of doing it means we would need to reindex the database once in a while
    /// (e.g. on a background thread), so that we don't end up with don't lose the sparcity of our
    /// indexes.
    func moveItems(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }

        let movingItem = items[sourceIndex]
        let destinationIndex = destination - 1

        let newIndex: Int64

        if destinationIndex < 0  {
            // Moved to the top
            let oldIndex = items.first!.orderIndex // yes, in production we probably don't want to force unwrap
            newIndex = oldIndex / 2
        } else if destinationIndex >= items.count - 1 {
            // Moved to the bottom
            let oldIndex = items.last!.orderIndex // yes, in production we probably don't want to force unwrap
            newIndex = oldIndex + 1000
        } else {
            // Moved to a middle position
            let beforeItem = items[max(0, destinationIndex)]
            let afterItem = items[min(items.count - 1, destinationIndex + 1)]
            newIndex = (beforeItem.orderIndex + afterItem.orderIndex) / 2
        }

        movingItem.orderIndex = newIndex

        do {
            try viewContext.save()
        } catch {
            // Handle the save error
            print("Failed to save context: \(error)")
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
