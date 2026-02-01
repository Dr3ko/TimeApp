//
//  EntriesView.swift
//  TimeApp
//

import SwiftUI
import SwiftData

struct EntriesView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = EntriesViewModel()
    @State private var editingEntry: TimeEntry?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Period Filter & Date Picker
                periodFilterAndDatePicker

                // Total Period
                totalHeader

                // Entries List
                entriesList
            }
            .navigationTitle(L10n.entriesTitle)
            .onAppear {
                viewModel.configure(with: modelContext)
            }
            .sheet(item: $editingEntry) { entry in
                EditEntryView(entry: entry) {
                    viewModel.fetchEntries()
                }
            }
        }
    }

    private var periodFilterAndDatePicker: some View {
        VStack(spacing: 8) {
            // Period Segmented Control
            Picker(L10n.entriesPeriodLabel, selection: $viewModel.selectedPeriod) {
                ForEach(PeriodFilter.allCases, id: \.self) { filter in
                    Text(filter.localizedValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: viewModel.selectedPeriod) { _, _ in
                viewModel.fetchEntries()
            }

            // Date Picker (changes based on period)
            datePicker
        }
        .padding(.vertical)
    }

    @ViewBuilder
    private var datePicker: some View {
        switch viewModel.selectedPeriod {
        case .day:
            DatePicker(
                L10n.entriesDateLabel,
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .onChange(of: viewModel.selectedDate) { _, _ in
                viewModel.fetchEntries()
            }

        case .month:
            DatePicker(
                L10n.entriesMonthLabel,
                selection: $viewModel.selectedMonth,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .onChange(of: viewModel.selectedMonth) { _, _ in
                viewModel.fetchEntries()
            }

        case .year:
            DatePicker(
                L10n.entriesYearLabel,
                selection: $viewModel.selectedYear,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .onChange(of: viewModel.selectedYear) { _, _ in
                viewModel.fetchEntries()
            }
        }
    }

    private var totalHeader: some View {
        HStack {
            Text(viewModel.totalPeriodLabel)
                .font(.headline)
            Spacer()
            Text(viewModel.formattedTotalPeriod)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
    }

    private var entriesList: some View {
        Group {
            if viewModel.groupedEntries.isEmpty {
                ContentUnavailableView(
                    L10n.entriesEmptyTitle,
                    systemImage: "clock",
                    description: Text(L10n.entriesEmptyMessage)
                )
            } else {
                List {
                    ForEach(viewModel.groupedEntries) { group in
                        Section {
                            ForEach(group.entries) { entry in
                                EntryRowView(entry: entry)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editingEntry = entry
                                    }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    viewModel.deleteEntry(group.entries[index])
                                }
                            }
                        } header: {
                            HStack {
                                Text(group.formattedDate)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                if group.isToday {
                                    Text(L10n.entriesToday)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(group.formattedTotal)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

struct EntryRowView: View {
    let entry: TimeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.project?.name ?? L10n.timerUnknown)
                    .font(.headline)

                Spacer()

                Text(entry.formattedDuration)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(entry.isRunning ? .green : .primary)

                if entry.isRunning {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                }
            }

            HStack {
                Text(formatTimeRange(entry))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !entry.note.isEmpty {
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(entry.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatTimeRange(_ entry: TimeEntry) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let start = formatter.string(from: entry.startedAt)
        if let end = entry.endedAt {
            return "\(start) - \(formatter.string(from: end))"
        }
        return "\(start) - \(L10n.entriesRunning)"
    }
}

struct EditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let entry: TimeEntry
    let onSave: () -> Void

    @State private var note: String = ""
    @State private var startedAt: Date = Date()
    @State private var endedAt: Date = Date()
    @State private var hasEndTime: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.entriesEditProject) {
                    Text(entry.project?.name ?? L10n.timerUnknown)
                        .foregroundStyle(.secondary)
                }

                Section(L10n.entriesEditTime) {
                    DatePicker(L10n.entriesEditStart, selection: $startedAt)

                    if hasEndTime {
                        DatePicker(L10n.entriesEditEnd, selection: $endedAt)
                    }
                }

                Section(L10n.entriesEditNote) {
                    TextField(L10n.entriesEditNote, text: $note)
                }
            }
            .navigationTitle(L10n.entriesEditTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.entriesEditCancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.entriesEditSave) {
                        saveEntry()
                    }
                }
            }
            .onAppear {
                note = entry.note
                startedAt = entry.startedAt
                hasEndTime = entry.endedAt != nil
                endedAt = entry.endedAt ?? Date()
            }
        }
    }

    private func saveEntry() {
        entry.note = note
        entry.startedAt = startedAt
        entry.endedAt = hasEndTime ? endedAt : nil

        try? modelContext.save()
        onSave()
        dismiss()
    }
}

#Preview {
    EntriesView()
        .modelContainer(for: [Project.self, TimeEntry.self], inMemory: true)
}
