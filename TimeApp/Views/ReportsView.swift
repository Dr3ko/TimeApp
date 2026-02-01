//
//  ReportsView.swift
//  TimeApp
//

import SwiftUI
import SwiftData

struct ReportsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ReportsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Summary Card
                    weeklySummaryCard

                    // Project Breakdown
                    if !viewModel.projectSummaries.isEmpty {
                        projectBreakdownSection
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle(L10n.reportsTitle)
            .onAppear {
                viewModel.configure(with: modelContext)
            }
            .refreshable {
                viewModel.fetchWeeklyReport()
            }
        }
    }

    private var weeklySummaryCard: some View {
        VStack(spacing: 12) {
            Text(L10n.reportsWeek)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(viewModel.formattedWeeklyTotal)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)

            Text(viewModel.weekDateRange)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var projectBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.reportsByProject)
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 8) {
                ForEach(viewModel.projectSummaries) { summary in
                    ProjectSummaryRow(
                        summary: summary,
                        maxSeconds: viewModel.projectSummaries.first?.totalSeconds ?? 1
                    )
                }
            }
        }
    }
}

struct ProjectSummaryRow: View {
    let summary: ProjectSummary
    let maxSeconds: Int

    private var progress: Double {
        guard maxSeconds > 0 else { return 0 }
        return Double(summary.totalSeconds) / Double(maxSeconds)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(summary.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(summary.formattedDuration)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(.blue)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ReportsView()
        .modelContainer(for: [Project.self, TimeEntry.self], inMemory: true)
}
