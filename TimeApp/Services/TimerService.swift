//
//  TimerService.swift
//  TimeApp
//

import Foundation
import SwiftData
import Combine

/// Manages the running timer state and ensures only one timer runs at a time
@MainActor
final class TimerService: ObservableObject {
    static let shared = TimerService()

    @Published var runningEntry: TimeEntry?
    @Published var elapsedSeconds: Int = 0

    private var timer: Timer?
    private var modelContext: ModelContext?

    private init() {}

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        findRunningEntry()
    }

    /// Find any running entry on app launch
    func findRunningEntry() {
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate<TimeEntry> { $0.endedAt == nil }
        )

        do {
            let runningEntries = try modelContext.fetch(descriptor)
            if let entry = runningEntries.first {
                self.runningEntry = entry
                self.elapsedSeconds = entry.durationSeconds
                startDisplayTimer()
            }
        } catch {
            print("Error fetching running entry: \(error)")
        }
    }

    /// Start a new timer for the given project
    func startTimer(for project: Project, note: String = "") {
        guard let modelContext = modelContext else { return }

        // Stop any running timer first
        if let running = runningEntry {
            running.stop()
        }

        // Create new entry
        let entry = TimeEntry(project: project, note: note)
        modelContext.insert(entry)

        do {
            try modelContext.save()
        } catch {
            print("Error saving new entry: \(error)")
        }

        runningEntry = entry
        elapsedSeconds = 0
        startDisplayTimer()
    }

    /// Stop the current running timer
    func stopTimer() {
        guard let modelContext = modelContext else { return }

        runningEntry?.stop()

        do {
            try modelContext.save()
        } catch {
            print("Error stopping entry: \(error)")
        }

        stopDisplayTimer()
        runningEntry = nil
        elapsedSeconds = 0
    }

    /// Start the display timer (updates UI every second)
    private func startDisplayTimer() {
        stopDisplayTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                guard let self = self, let entry = self.runningEntry else { return }
                self.elapsedSeconds = entry.durationSeconds
            }
        }
    }

    /// Stop the display timer
    private func stopDisplayTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Format seconds to HH:MM:SS
    func formattedElapsedTime() -> String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let secs = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    /// Check if timer is running
    var isRunning: Bool {
        runningEntry != nil
    }
}
