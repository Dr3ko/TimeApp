//
//  TimerViewModel.swift
//  TimeApp
//

import Foundation
import SwiftData
import Combine

@MainActor
final class TimerViewModel: ObservableObject {
    @Published var selectedProject: Project?
    @Published var note: String = ""
    @Published var projects: [Project] = []

    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()

    let timerService = TimerService.shared

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        timerService.configure(with: modelContext)
        fetchProjects()

        // If there's a running entry, set the selected project
        if let running = timerService.runningEntry {
            selectedProject = running.project
            note = running.note
        }
    }

    func fetchProjects() {
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate<Project> { !$0.isArchived },
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            projects = try modelContext.fetch(descriptor)
            // Auto-select first project if none selected
            if selectedProject == nil && !projects.isEmpty {
                selectedProject = projects.first
            }
        } catch {
            print("Error fetching projects: \(error)")
        }
    }

    func startTimer() {
        guard let project = selectedProject else { return }
        timerService.startTimer(for: project, note: note)
    }

    func stopTimer() {
        timerService.stopTimer()
        note = ""
    }

    var isRunning: Bool {
        timerService.isRunning
    }

    var elapsedTime: String {
        timerService.formattedElapsedTime()
    }

    var runningProjectName: String {
        timerService.runningEntry?.project?.name ?? L10n.timerUnknown
    }
}
