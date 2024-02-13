//
//  ContentView.swift
//  HealthApp
//
//  Created by Will on 2/13/24.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.orderIndex, ascending: true)],
        animation: .default)
    var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items.indices, id: \.self) { index in
                    Text(items[index].name ?? "Unknown")
                }
                .onMove(perform: moveItems)
            }
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        // Implementation assumes 'orderIndex' is managed and consistent across items
        var revisedItems = items.map { $0 }
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update the orderIndex for all items
        for index in revisedItems.indices {
            revisedItems[index].orderIndex = Int64(index)
        }

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
