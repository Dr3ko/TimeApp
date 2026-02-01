//
//  TimerView.swift
//  TimeApp
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TimerViewModel()
    @ObservedObject private var timerService = TimerService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Timer Display
                timerDisplay

                // Running indicator
                if timerService.isRunning {
                    runningIndicator
                }

                Spacer()

                // Project Picker
                if !viewModel.projects.isEmpty {
                    projectPicker
                } else {
                    noProjectsView
                }

                // Note Field
                noteField

                // Start/Stop Button
                actionButton

                Spacer()
            }
            .padding()
            .navigationTitle(L10n.timerTitle)
            .onAppear {
                viewModel.configure(with: modelContext)
            }
        }
    }

    private var timerDisplay: some View {
        Text(timerService.formattedElapsedTime())
            .font(.system(size: 72, weight: .thin, design: .monospaced))
            .foregroundStyle(timerService.isRunning ? .green : .primary)
    }

    private var runningIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(.green)
                .frame(width: 10, height: 10)

            Text(viewModel.runningProjectName)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.green.opacity(0.1))
        .cornerRadius(20)
    }

    private var projectPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.timerProjectLabel)
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker(L10n.timerProjectPlaceholder, selection: $viewModel.selectedProject) {
                ForEach(viewModel.projects) { project in
                    Text(project.name).tag(project as Project?)
                }
            }
            .pickerStyle(.menu)
            .disabled(timerService.isRunning)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var noProjectsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "folder.badge.plus")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(L10n.timerNoProjectsTitle)
                .font(.headline)
            Text(L10n.timerNoProjectsMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.timerNoteLabel)
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(L10n.timerNotePlaceholder, text: $viewModel.note)
                .textFieldStyle(.roundedBorder)
                .disabled(timerService.isRunning)
        }
    }

    private var actionButton: some View {
        Button(action: {
            if timerService.isRunning {
                viewModel.stopTimer()
            } else {
                viewModel.startTimer()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: timerService.isRunning ? "stop.fill" : "play.fill")
                Text(timerService.isRunning ? L10n.timerStop : L10n.timerStart)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(timerService.isRunning ? .red : .green)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.selectedProject == nil && !timerService.isRunning)
    }
}

#Preview {
    TimerView()
        .modelContainer(for: [Project.self, TimeEntry.self], inMemory: true)
}
