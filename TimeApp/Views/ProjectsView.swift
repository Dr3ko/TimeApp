//
//  ProjectsView.swift
//  TimeApp
//

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProjectsViewModel()

    @State private var showingAddProject = false
    @State private var newProjectName = ""
    @State private var newProjectTargetHours: String = ""
    @State private var editingProject: Project?
    @State private var editProjectName = ""
    @State private var editProjectTargetHours: String = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.projects.isEmpty {
                    emptyView
                } else {
                    projectsList
                }
            }
            .navigationTitle(L10n.projectsTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddProject = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.configure(with: modelContext)
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectSheet(
                    projectName: $newProjectName,
                    targetHours: $newProjectTargetHours,
                    onSave: { name, target in
                        viewModel.addProject(name: name, monthlyTargetHours: target)
                        newProjectName = ""
                        newProjectTargetHours = ""
                        showingAddProject = false
                    },
                    onCancel: {
                        newProjectName = ""
                        newProjectTargetHours = ""
                        showingAddProject = false
                    }
                )
            }
            .sheet(item: Binding(
                get: { editingProject.map { EditProjectSheetInfo(project: $0, name: editProjectName, target: editProjectTargetHours) } },
                set: { if $0 == nil { editingProject = nil } }
            )) { info in
                EditProjectSheet(
                    projectName: $editProjectName,
                    targetHours: $editProjectTargetHours,
                    currentTarget: info.project.monthlyTargetHours,
                    onSave: { name, target in
                        viewModel.renameProject(info.project, to: name, monthlyTargetHours: target)
                        editingProject = nil
                        editProjectName = ""
                        editProjectTargetHours = ""
                    },
                    onCancel: {
                        editingProject = nil
                        editProjectName = ""
                        editProjectTargetHours = ""
                    }
                )
            }
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            L10n.projectsEmptyTitle,
            systemImage: "folder",
            description: Text(L10n.projectsEmptyMessage)
        )
    }

    private var projectsList: some View {
        List {
            ForEach(viewModel.projects) { project in
                ProjectRowView(project: project)
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button {
                            editProjectName = project.name
                            editProjectTargetHours = project.monthlyTargetHours.map { String($0) } ?? ""
                            editingProject = project
                        } label: {
                            Label(L10n.projectsEdit, systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            viewModel.deleteProject(project)
                        } label: {
                            Label(L10n.projectsDelete, systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.deleteProject(project)
                        } label: {
                            Label(L10n.projectsDelete, systemImage: "trash")
                        }

                        Button {
                            editProjectName = project.name
                            editProjectTargetHours = project.monthlyTargetHours.map { String($0) } ?? ""
                            editingProject = project
                        } label: {
                            Label(L10n.projectsEdit, systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct EditProjectSheetInfo: Identifiable {
    let id = UUID()
    let project: Project
    let name: String
    let target: String
}

struct ProjectRowView: View {
    let project: Project

    @State private var calculation: ProjectTargetCalculation?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.name)
                .font(.headline)

            Text(L10n.projectsEntriesCount(project.entries.count))
                .font(.caption)
                .foregroundStyle(.secondary)

            if let calc = calculation {
                Divider()

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(L10n.projectsStatsThisMonth)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.1fh / %.1fh", calc.realizedCurrentMonth, calc.targetCurrentMonth))
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }

                    HStack {
                        Text(L10n.projectsStatsCarry)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(calc.formattedCarry)
                            .font(.caption)
                            .foregroundStyle(calc.carryPreviousMonths >= 0 ? .green : .red)
                    }

                    if calc.isCompleteThisMonth {
                        Text(L10n.projectsStatsComplete)
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else {
                        HStack {
                            Text(L10n.projectsStatsRemaining)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(L10n.timeFormatHoursOnly(calc.remainingThisMonth))
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            updateCalculation()
        }
        .onChange(of: project.entries.count) { _, _ in
            updateCalculation()
        }
    }

    private func updateCalculation() {
        calculation = ProjectTargetCalculator.calculate(
            for: project,
            entries: project.entries
        )
    }
}

#Preview {
    ProjectsView()
        .modelContainer(for: [Project.self, TimeEntry.self], inMemory: true)
}

// MARK: - Add Project Sheet

struct AddProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var projectName: String
    @Binding var targetHours: String
    let onSave: (String, Double?) -> Void
    let onCancel: () -> Void

    @FocusState private var focusedField: Field?

    enum Field {
        case name, target
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.projectsAddNameSection) {
                    TextField(L10n.projectsAddNamePlaceholder, text: $projectName)
                        .focused($focusedField, equals: .name)
                        .onSubmit {
                            focusedField = .target
                        }
                }

                Section(L10n.projectsAddTargetSection) {
                    HStack {
                        TextField(L10n.projectsAddTargetPlaceholder, text: $targetHours)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .target)

                        if !targetHours.isEmpty {
                            Text(L10n.projectsAddTargetHoursSuffix)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(L10n.projectsAddTargetHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(L10n.projectsAddTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.projectsAddCancel) {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.projectsAddSave) {
                        let target = parseTargetHours()
                        onSave(projectName, target)
                    }
                    .disabled(projectName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                focusedField = .name
            }
        }
    }

    private func parseTargetHours() -> Double? {
        guard !targetHours.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }
        guard let value = Double(targetHours), value >= 0 else {
            return nil
        }
        return value
    }
}

// MARK: - Edit Project Sheet

struct EditProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var projectName: String
    @Binding var targetHours: String
    let currentTarget: Double?
    let onSave: (String, Double?) -> Void
    let onCancel: () -> Void

    @FocusState private var focusedField: Field?

    enum Field {
        case name, target
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.projectsAddNameSection) {
                    TextField(L10n.projectsAddNamePlaceholder, text: $projectName)
                        .focused($focusedField, equals: .name)
                        .onSubmit {
                            focusedField = .target
                        }
                }

                Section(L10n.projectsAddTargetSection) {
                    HStack {
                        TextField(L10n.projectsAddTargetPlaceholder, text: $targetHours)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .target)

                        if !targetHours.isEmpty {
                            Text(L10n.projectsAddTargetHoursSuffix)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(L10n.projectsAddTargetHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let current = currentTarget {
                        Text(L10n.projectsEditTargetCurrent(current))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(L10n.projectsEditTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.projectsAddCancel) {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.projectsAddSave) {
                        let target = parseTargetHours()
                        onSave(projectName, target)
                    }
                    .disabled(projectName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                focusedField = .name
            }
        }
    }

    private func parseTargetHours() -> Double? {
        guard !targetHours.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }
        guard let value = Double(targetHours), value >= 0 else {
            return nil
        }
        return value
    }
}
