//
//  TimeEntry.swift
//  TimeApp
//

import Foundation
import SwiftData

@Model
final class TimeEntry {
    var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var note: String
    var project: Project?

    /// Calculated duration in seconds
    var durationSeconds: Int {
        guard let endedAt = endedAt else {
            return Int(Date().timeIntervalSince(startedAt))
        }
        return Int(endedAt.timeIntervalSince(startedAt))
    }

    /// Check if this entry is currently running
    var isRunning: Bool {
        endedAt == nil
    }

    init(project: Project, note: String = "") {
        self.id = UUID()
        self.startedAt = Date()
        self.endedAt = nil
        self.note = note
        self.project = project
    }

    /// Stop the timer and record end time
    func stop() {
        if endedAt == nil {
            endedAt = Date()
        }
    }

    /// Formatted duration string (HH:MM:SS)
    var formattedDuration: String {
        let seconds = durationSeconds
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}
