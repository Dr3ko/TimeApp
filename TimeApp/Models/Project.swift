//
//  Project.swift
//  TimeApp
//

import Foundation
import SwiftData

@Model
final class Project {
    var id: UUID
    var name: String
    var createdAt: Date
    var isArchived: Bool

    /// Monthly target hours set by user. If nil, no target tracking for this project.
    var monthlyTargetHours: Double?

    @Relationship(deleteRule: .cascade, inverse: \TimeEntry.project)
    var entries: [TimeEntry] = []

    init(name: String, monthlyTargetHours: Double? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.isArchived = false
        self.monthlyTargetHours = monthlyTargetHours
    }
}
