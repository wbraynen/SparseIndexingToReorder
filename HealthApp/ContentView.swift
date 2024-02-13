//
//  ContentView.swift
//  HealthApp
//
//  Created by Will on 2/13/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var activities: [String] = [
        "A", "B", "C", "D"
    ]

    var body: some View {
        List {
            ForEach(activities, id: \.self) { activity in
                Text(activity)
            }.onMove { from, to in
                activities.move(fromOffsets: from, toOffset: to)
            }
        }
    }
}
