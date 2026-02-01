//
//  Localization.swift
//  TimeApp
//
//  Helper pentru localizare
//

import Foundation

enum L10n {
    // Helper pentru a accesa ușor string-urile localizate
    static func string(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    // Helper pentru string-uri cu formatare
    static func string(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: string(key), arguments: arguments)
    }
}

// MARK: - Tab Bar
extension L10n {
    static var timerTab: String { string("timer.tab") }
    static var entriesTab: String { string("entries.tab") }
    static var projectsTab: String { string("projects.tab") }
    static var reportsTab: String { string("reports.tab") }
}

// MARK: - Timer
extension L10n {
    static var timerTitle: String { string("timer.title") }
    static var timerProjectLabel: String { string("timer.project.label") }
    static var timerProjectPlaceholder: String { string("timer.project.placeholder") }
    static var timerNoProjectsTitle: String { string("timer.no_projects.title") }
    static var timerNoProjectsMessage: String { string("timer.no_projects.message") }
    static var timerNoteLabel: String { string("timer.note.label") }
    static var timerNotePlaceholder: String { string("timer.note.placeholder") }
    static var timerStart: String { string("timer.start") }
    static var timerStop: String { string("timer.stop") }
    static var timerUnknown: String { string("timer.unknown") }
}

// MARK: - Entries
extension L10n {
    static var entriesTitle: String { string("entries.title") }
    static var entriesPeriodLabel: String { string("entries.period.label") }
    static var entriesPeriodDay: String { string("entries.period.day") }
    static var entriesPeriodMonth: String { string("entries.period.month") }
    static var entriesPeriodYear: String { string("entries.period.year") }
    static var entriesDateLabel: String { string("entries.date.label") }
    static var entriesMonthLabel: String { string("entries.month.label") }
    static var entriesYearLabel: String { string("entries.year.label") }
    static var entriesProjectLabel: String { string("entries.project.label") }
    static var entriesProjectAll: String { string("entries.project.all") }
    static var entriesTotalToday: String { string("entries.total.today") }
    static func entriesTotalMonth(_ month: String) -> String { string("entries.total.month_format", month) }
    static func entriesTotalYear(_ year: String) -> String { string("entries.total.year_format", year) }
    static var entriesEmptyTitle: String { string("entries.empty.title") }
    static var entriesEmptyMessage: String { string("entries.empty.message") }
    static var entriesToday: String { string("entries.today") }
    static var entriesRunning: String { string("entries.running") }

    static var entriesEditTitle: String { string("entries.edit.title") }
    static var entriesEditProject: String { string("entries.edit.project") }
    static var entriesEditTime: String { string("entries.edit.time") }
    static var entriesEditStart: String { string("entries.edit.start") }
    static var entriesEditEnd: String { string("entries.edit.end") }
    static var entriesEditNote: String { string("entries.edit.note") }
    static var entriesEditCancel: String { string("entries.edit.cancel") }
    static var entriesEditSave: String { string("entries.edit.save") }
}

// MARK: - Export
extension L10n {
    static var exportTitle: String { string("export.title") }
    static var exportPeriod: String { string("export.period") }
    static var exportTotalDay: String { string("export.total_day") }
}

// MARK: - Projects
extension L10n {
    static var projectsTitle: String { string("projects.title") }
    static var projectsEmptyTitle: String { string("projects.empty.title") }
    static var projectsEmptyMessage: String { string("projects.empty.message") }
    static var projectsEdit: String { string("projects.edit") }
    static var projectsDelete: String { string("projects.delete") }
    static func projectsEntriesCount(_ count: Int) -> String {
        String(format: string("projects.entries.count"), count)
    }

    // Add Project
    static var projectsAddTitle: String { string("projects.add.title") }
    static var projectsAddNameSection: String { string("projects.add.name_section") }
    static var projectsAddNamePlaceholder: String { string("projects.add.name_placeholder") }
    static var projectsAddTargetSection: String { string("projects.add.target_section") }
    static var projectsAddTargetPlaceholder: String { string("projects.add.target_placeholder") }
    static var projectsAddTargetHoursSuffix: String { string("projects.add.target_hours_suffix") }
    static var projectsAddTargetHint: String { string("projects.add.target_hint") }
    static var projectsAddCancel: String { string("projects.add.cancel") }
    static var projectsAddSave: String { string("projects.add.save") }

    // Edit Project
    static var projectsEditTitle: String { string("projects.edit.title") }
    static func projectsEditTargetCurrent(_ target: Double) -> String {
        String(format: string("projects.edit.target_current"), target)
    }

    // Project Row Stats
    static var projectsStatsThisMonth: String { string("projects.stats.this_month") }
    static var projectsStatsCarry: String { string("projects.stats.carry") }
    static var projectsStatsComplete: String { string("projects.stats.complete") }
    static var projectsStatsRemaining: String { string("projects.stats.remaining") }
}

// MARK: - Reports
extension L10n {
    static var reportsTitle: String { string("reports.title") }
    static var reportsWeek: String { string("reports.week") }
    static var reportsByProject: String { string("reports.by_project") }
}

// MARK: - Time Format
extension L10n {
    static func timeFormatHoursMinutes(_ hours: Int, _ minutes: Int) -> String {
        String(format: string("time.format.hours_minutes"), hours, minutes)
    }

    static func timeFormatHoursOnly(_ hours: Double) -> String {
        String(format: string("time.format.hours_only"), hours)
    }
}
