//
//  ContentView.swift
//  TimeApp
//
//  Created by Cazacu Marius Constantin on 01.02.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Project.self, TimeEntry.self], inMemory: true)
}
