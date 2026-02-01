//
//  ProjectsViewModel.swift
//  TimeApp
//

import Foundation
import SwiftData
import Combine

@MainActor
final class ProjectsViewModel: ObservableObject {
    @Published var projects: [Project] = []

    private var modelContext: ModelContext?

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchProjects()
    }

    func fetchProjects() {
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate<Project> { !$0.isArchived },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            projects = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching projects: \(error)")
        }
    }

    func addProject(name: String, monthlyTargetHours: Double?) {
        guard let modelContext = modelContext else { return }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let project = Project(name: name.trimmingCharacters(in: .whitespaces), monthlyTargetHours: monthlyTargetHours)
        modelContext.insert(project)

        do {
            try modelContext.save()
            fetchProjects()
        } catch {
            print("Error adding project: \(error)")
        }
    }

    func renameProject(_ project: Project, to newName: String, monthlyTargetHours: Double?) {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        project.name = newName.trimmingCharacters(in: .whitespaces)
        project.monthlyTargetHours = monthlyTargetHours

        do {
            try modelContext?.save()
            fetchProjects()
        } catch {
            print("Error renaming project: \(error)")
        }
    }

    func deleteProject(_ project: Project) {
        guard let modelContext = modelContext else { return }

        // Check if project has entries - if so, archive instead of delete
        if !project.entries.isEmpty {
            project.isArchived = true
        } else {
            modelContext.delete(project)
        }

        do {
            try modelContext.save()
            fetchProjects()
        } catch {
            print("Error deleting project: \(error)")
        }
    }
}
