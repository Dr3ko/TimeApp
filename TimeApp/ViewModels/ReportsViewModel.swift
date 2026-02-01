//
//  ReportsViewModel.swift
//  TimeApp
//

import Foundation
import SwiftData
import Combine

struct ProjectSummary: Identifiable {
    let id: UUID
    let name: String
    let totalSeconds: Int

    var formattedDuration: String {
        L10n.timeFormatHoursMinutes(totalSeconds / 3600, (totalSeconds % 3600) / 60)
    }
}

@MainActor
final class ReportsViewModel: ObservableObject {
    @Published var weeklyTotalSeconds: Int = 0
    @Published var projectSummaries: [ProjectSummary] = []

    private var modelContext: ModelContext?

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchWeeklyReport()
    }

    func fetchWeeklyReport() {
        guard let modelContext = modelContext else { return }

        let calendar = Calendar.current
        let now = Date()

        // Get start of current week (Monday)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        components.weekday = 2 // Monday
        let startOfWeek = calendar.date(from: components) ?? now

        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        let descriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate<TimeEntry> {
                $0.startedAt >= startOfWeek && $0.startedAt < endOfWeek && $0.endedAt != nil
            }
        )

        do {
            let entries = try modelContext.fetch(descriptor)

            // Calculate total weekly
            weeklyTotalSeconds = entries.reduce(0) { $0 + $1.durationSeconds }

            // Group by project
            var projectTotals: [UUID: (name: String, seconds: Int)] = [:]
            for entry in entries {
                if let project = entry.project {
                    let current = projectTotals[project.id] ?? (name: project.name, seconds: 0)
                    projectTotals[project.id] = (name: project.name, seconds: current.seconds + entry.durationSeconds)
                }
            }

            // Convert to summaries and sort by duration
            projectSummaries = projectTotals.map { key, value in
                ProjectSummary(id: key, name: value.name, totalSeconds: value.seconds)
            }.sorted { $0.totalSeconds > $1.totalSeconds }

        } catch {
            print("Error fetching weekly report: \(error)")
        }
    }

    var formattedWeeklyTotal: String {
        L10n.timeFormatHoursMinutes(weeklyTotalSeconds / 3600, (weeklyTotalSeconds % 3600) / 60)
    }

    var weekDateRange: String {
        let calendar = Calendar.current
        let now = Date()

        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        components.weekday = 2
        let startOfWeek = calendar.date(from: components) ?? now
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"

        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
}
