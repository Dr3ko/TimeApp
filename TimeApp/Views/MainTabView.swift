//
//  MainTabView.swift
//  TimeApp
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView()
                .tabItem {
                    Label(L10n.timerTab, systemImage: "timer")
                }
                .tag(0)

            EntriesView()
                .tabItem {
                    Label(L10n.entriesTab, systemImage: "list.bullet.clipboard")
                }
                .tag(1)

            ProjectsView()
                .tabItem {
                    Label(L10n.projectsTab, systemImage: "folder")
                }
                .tag(2)

            ReportsView()
                .tabItem {
                    Label(L10n.reportsTab, systemImage: "chart.bar")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Project.self, TimeEntry.self], inMemory: true)
}
