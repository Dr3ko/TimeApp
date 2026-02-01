//
//  ProjectTargetCalculator.swift
//  TimeApp
//
//  Helper pentru calculul target-ului de ore/lună cu carry-over
//

import Foundation

/// Rezultatul calculului target-ului pentru un proiect
struct ProjectTargetCalculation {
    let monthlyTarget: Double
    let realizedCurrentMonth: Double
    let targetCurrentMonth: Double
    let carryPreviousMonths: Double
    let remainingThisMonth: Double
    let statusThisMonth: Double
    let numberOfClosedMonths: Int

    /// Formatează un număr de ore cu prefix +/- pentru carry
    var formattedCarry: String {
        if carryPreviousMonths >= 0 {
            return String(format: "+%.1fh", carryPreviousMonths)
        } else {
            return String(format: "%.1fh", carryPreviousMonths)
        }
    }

    /// Text pentru "Gata pe luna asta" când remaining e 0
    var isCompleteThisMonth: Bool {
        remainingThisMonth == 0
    }
}

/// Calculator pentru target-uri de ore per proiect
enum ProjectTargetCalculator {

    /// Calculează target-ul și soldul pentru un proiect
    /// - Parameters:
    ///   - project: Proiectul pentru care se face calculul
    ///   - entries: Toate entries-urile asociate proiectului
    ///   - calendar: Calendarul folosit (default: current)
    /// - Returns: ProjectTargetCalculation cu toate valorile calculate, sau nil dacă nu există target setat
    static func calculate(
        for project: Project,
        entries: [TimeEntry],
        calendar: Calendar = .current
    ) -> ProjectTargetCalculation? {
        guard let monthlyTarget = project.monthlyTargetHours, monthlyTarget > 0 else {
            return nil
        }

        let now = Date()
        let currentMonth = calendar.dateInterval(of: .month, for: now)!

        // Filtrăm doar entries-urile finalizate
        let completedEntries = entries.filter { $0.endedAt != nil }

        // Găsim prima lună cu entries
        let firstEntryDate = completedEntries.map(\.startedAt).min()
        let firstMonth = firstEntryDate.flatMap { calendar.dateInterval(of: .month, for: $0) }

        // Calculăm lunile închise (toate lunile complete înainte de luna curentă)
        let closedMonths = calculateClosedMonths(
            currentMonth: currentMonth,
            firstMonth: firstMonth,
            calendar: calendar
        )

        // Calculăm orele realizate în lunile închise
        let realizedClosedMonths = calculateHoursForMonths(
            closedMonths,
            in: completedEntries,
            calendar: calendar
        )

        // Target total pentru lunile închise
        let numberOfClosedMonths = closedMonths.count
        let targetClosedMonths = monthlyTarget * Double(numberOfClosedMonths)

        // Carry din lunile trecute
        let carryPreviousMonths = realizedClosedMonths - targetClosedMonths

        // Ore realizate în luna curentă
        let realizedCurrentMonth = calculateHoursForMonth(
            currentMonth,
            in: completedEntries,
            calendar: calendar
        )

        // Target pentru luna curentă
        let targetCurrentMonth = monthlyTarget

        // Credit și debt
        let credit = max(0, carryPreviousMonths)
        let debt = max(0, -carryPreviousMonths)

        // Remaining this month: max(0, (targetCurrentMonth - realizedCurrentMonth - credit) + debt)
        let remainingThisMonth = max(0, (targetCurrentMonth - realizedCurrentMonth - credit) + debt)

        // Status this month: (realizedCurrentMonth - targetCurrentMonth) + carryPreviousMonths
        let statusThisMonth = (realizedCurrentMonth - targetCurrentMonth) + carryPreviousMonths

        return ProjectTargetCalculation(
            monthlyTarget: monthlyTarget,
            realizedCurrentMonth: realizedCurrentMonth,
            targetCurrentMonth: targetCurrentMonth,
            carryPreviousMonths: carryPreviousMonths,
            remainingThisMonth: remainingThisMonth,
            statusThisMonth: statusThisMonth,
            numberOfClosedMonths: numberOfClosedMonths
        )
    }

    // MARK: - Private Helpers

    /// Returnează intervalele pentru toate lunile complete înainte de luna curentă
    private static func calculateClosedMonths(
        currentMonth: DateInterval,
        firstMonth: DateInterval?,
        calendar: Calendar
    ) -> [DateInterval] {
        guard let firstMonth = firstMonth else {
            return []
        }

        // Dacă prima lună e luna curentă, nu sunt luni închise
        guard firstMonth.start < currentMonth.start else {
            return []
        }

        var months: [DateInterval] = []
        var monthIterator = firstMonth

        // Iterăm prin toate lunile până la luna curentă ( exclusiv)
        while monthIterator.start < currentMonth.start {
            months.append(monthIterator)
            if let nextMonth = calendar.dateInterval(of: .month, for: monthIterator.end) {
                monthIterator = nextMonth
            } else {
                break
            }
        }

        return months
    }

    /// Calculează orele totale pentru o listă de luni
    private static func calculateHoursForMonths(
        _ months: [DateInterval],
        in entries: [TimeEntry],
        calendar: Calendar
    ) -> Double {
        months.reduce(0) { total, month in
            total + calculateHoursForMonth(month, in: entries, calendar: calendar)
        }
    }

    /// Calculează orele totale pentru o anumită lună
    private static func calculateHoursForMonth(
        _ month: DateInterval,
        in entries: [TimeEntry],
        calendar: Calendar
    ) -> Double {
        entries
            .filter { entry in
                entry.startedAt >= month.start && entry.startedAt < month.end
            }
            .reduce(0.0) { $0 + (Double($1.durationSeconds) / 3600.0) }
    }
}
