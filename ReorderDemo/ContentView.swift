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

                // On iOS 17, for some reason, contrary to [Apple's documentation](https://developer.apple.com/documentation/swiftui/progressview/),
                // this does not display a circular progress bar.
                // Instead, it just displays a spinner.
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

    // MARK: - Helpers

    /// Uses sparce indexing.
    ///
    /// This avoids having to copy the entire dataset into memory and saving the whole thing back.
    /// However, this way of doing it means we would need to reindex the database once in a while
    /// (e.g. on a background thread), so that we don't end up with don't lose the sparcity of our
    /// indexes.
    private func moveItems(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        let movingItem = items[sourceIndex]
        let destinationIndex = destination - 1

        movingItem.orderIndex = calculateNewIndex(forDestinationIndex: destinationIndex)

        saveViewContext()
    }

    /// `Int64` because of our database model.  Otherwise I would have just used the `Int` type.
    private func calculateNewIndex(forDestinationIndex destinationIndex: Int) -> Int64 {
        let newIndex: Int64

        if destinationIndex < 0 {
            // first items's index / 2
            newIndex = calculateIndexForTopPosition()
        } else if destinationIndex >= items.count - 1 {
            // last item's index + 1000
            newIndex = calculateIndexForBottomPosition()
        } else {
            // squeeze this in between the before and after items
            newIndex = calculateIndexForMiddlePosition(at: destinationIndex)
        }

        return newIndex
    }

    private func calculateIndexForTopPosition() -> Int64 {
        let oldIndex = items.first?.orderIndex ?? 0
        return oldIndex / 2
    }

    private func calculateIndexForBottomPosition() -> Int64 {
        let oldIndex = items.last?.orderIndex ?? 0
        return oldIndex + 1000
    }

    private func calculateIndexForMiddlePosition(at index: Int) -> Int64 {
        let beforeItem = items[max(0, index)]
        let afterItem = items[min(items.count - 1, index + 1)]
        return (beforeItem.orderIndex + afterItem.orderIndex) / 2
    }

    private func saveViewContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
