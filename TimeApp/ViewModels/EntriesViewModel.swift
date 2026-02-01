//
//  EntriesViewModel.swift
//  TimeApp
//

import Foundation
import SwiftData
import Combine

/// Perioada de filtrare pentru entries
enum PeriodFilter: String, CaseIterable {
    case day = "day"
    case month = "month"
    case year = "year"

    var localizedValue: String {
        switch self {
        case .day: return L10n.entriesPeriodDay
        case .month: return L10n.entriesPeriodMonth
        case .year: return L10n.entriesPeriodYear
        }
    }
}

/// Grupă de entries pe o zi
struct DayEntriesGroup: Identifiable {
    let id = UUID()
    let date: Date
    let entries: [TimeEntry]
    let totalSeconds: Int

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var formattedTotal: String {
        L10n.timeFormatHoursMinutes(totalSeconds / 3600, (totalSeconds % 3600) / 60)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

@MainActor
final class EntriesViewModel: ObservableObject {
    @Published var groupedEntries: [DayEntriesGroup] = []
    @Published var totalPeriodSeconds: Int = 0
    @Published var selectedDate: Date = Date()
    @Published var selectedPeriod: PeriodFilter = .month
    @Published var selectedMonth: Date = Date()
    @Published var selectedYear: Date = Date()
    @Published var availableProjects: [Project] = []
    @Published var selectedProject: Project?

    private var modelContext: ModelContext?

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchProjects()
        fetchEntries()
    }

    func fetchProjects() {
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate<Project> { !$0.isArchived },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            availableProjects = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching projects: \(error)")
            availableProjects = []
        }
    }

    func fetchEntries() {
        guard let modelContext = modelContext else { return }

        let calendar = Calendar.current
        let (startDate, endDate): (Date, Date)

        switch selectedPeriod {
        case .day:
            startDate = calendar.startOfDay(for: selectedDate)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        case .month:
            let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth)!
            startDate = monthInterval.start
            endDate = monthInterval.end
        case .year:
            let yearInterval = calendar.dateInterval(of: .year, for: selectedYear)!
            startDate = yearInterval.start
            endDate = yearInterval.end
        }

        let entries: [TimeEntry]

        if let project = selectedProject {
            // Filtrare pe proiect selectat
            let projectID = project.id
            let descriptor = FetchDescriptor<TimeEntry>(
                predicate: #Predicate<TimeEntry> {
                    $0.startedAt >= startDate && $0.startedAt < endDate && $0.project?.id == projectID
                },
                sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
            )
            do {
                entries = try modelContext.fetch(descriptor)
            } catch {
                print("Error fetching entries: \(error)")
                entries = []
            }
        } else {
            // Toate proiectele
            let descriptor = FetchDescriptor<TimeEntry>(
                predicate: #Predicate<TimeEntry> {
                    $0.startedAt >= startDate && $0.startedAt < endDate
                },
                sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
            )
            do {
                entries = try modelContext.fetch(descriptor)
            } catch {
                print("Error fetching entries: \(error)")
                entries = []
            }
        }

        groupEntriesByDay(entries)
        calculateTotalPeriod()
    }

    private func groupEntriesByDay(_ entries: [TimeEntry]) {
        let calendar = Calendar.current
        var grouped: [Date: [TimeEntry]] = [:]

        for entry in entries {
            let day = calendar.startOfDay(for: entry.startedAt)
            grouped[day, default: []].append(entry)
        }

        groupedEntries = grouped.map { date, entries in
            let total = entries
                .filter { $0.endedAt != nil }
                .reduce(0) { $0 + $1.durationSeconds }
            return DayEntriesGroup(date: date, entries: entries, totalSeconds: total)
        }
        .sorted { $0.date > $1.date }
    }

    private func calculateTotalPeriod() {
        totalPeriodSeconds = groupedEntries
            .flatMap { $0.entries }
            .filter { $0.endedAt != nil }
            .reduce(0) { $0 + $1.durationSeconds }
    }

    var formattedTotalPeriod: String {
        L10n.timeFormatHoursMinutes(totalPeriodSeconds / 3600, (totalPeriodSeconds % 3600) / 60)
    }

    var totalPeriodLabel: String {
        switch selectedPeriod {
        case .day:
            return L10n.entriesTotalToday
        case .month:
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString("date.format.month_year", comment: "")
            let monthString = formatter.string(from: selectedMonth)
            return L10n.entriesTotalMonth(monthString)
        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = NSLocalizedString("date.format.year_only", comment: "")
            let yearString = formatter.string(from: selectedYear)
            return L10n.entriesTotalYear(yearString)
        }
    }

    func deleteEntry(_ entry: TimeEntry) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(entry)

        do {
            try modelContext.save()
            fetchEntries()
        } catch {
            print("Error deleting entry: \(error)")
        }
    }

    func updateEntry(_ entry: TimeEntry, note: String, startedAt: Date, endedAt: Date?) {
        entry.note = note
        entry.startedAt = startedAt
        entry.endedAt = endedAt

        do {
            try modelContext?.save()
            fetchEntries()
        } catch {
            print("Error updating entry: \(error)")
        }
    }
}
