//
//  ExportService.swift
//  TimeApp
//
//  Serviciu pentru exportul entries în format PDF
//

import Foundation
import SwiftUI
import UIKit

struct ExportData {
    let periodLabel: String
    let projectLabel: String
    let totalPeriod: String
    let groupedEntries: [DayEntriesGroup]
}

@MainActor
final class ExportService {

    static let shared = ExportService()

    private init() {}

    /// Generează PDF pentru export și îl returnează ca URL
    func generatePDF(from data: ExportData) throws -> URL {
        // 1. Creare string HTML pentru PDF
        let htmlContent = generateHTML(from: data)

        // 2. Salvare fișier temporar
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "TimeApp_Export_\(Date().timeIntervalSince1970).pdf"
        let fileURL = tempDir.appendingPathComponent(filename)

        // 3. Render HTML la PDF
        let renderer = UIPrintPageRenderer()
        let formatter = UIMarkupTextPrintFormatter(markupText: htmlContent)

        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)

        // 4. Setup page dimensions
        let page = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size in points
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(page, forKey: "printableRect")

        // 5. Creare PDF data
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)

        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext()

        // 6. Scriere PDF la fișier
        try pdfData.write(to: fileURL)

        return fileURL
    }

    /// Generează HTML pentru PDF
    private func generateHTML(from data: ExportData) -> String {
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Helvetica Neue', sans-serif;
                    padding: 20px;
                    margin: 0;
                    background-color: #f5f5f5;
                }
                .container {
                    max-width: 800px;
                    margin: 0 auto;
                    background-color: white;
                    padding: 30px;
                    border-radius: 10px;
                }
                .header {
                    border-bottom: 2px solid #007AFF;
                    padding-bottom: 15px;
                    margin-bottom: 20px;
                }
                .header h1 {
                    color: #007AFF;
                    font-size: 24px;
                    margin: 0 0 10px 0;
                }
                .header-info {
                    font-size: 14px;
                    color: #666;
                    line-height: 1.6;
                }
                .total {
                    background-color: #E3F2FD;
                    padding: 10px 15px;
                    border-radius: 8px;
                    font-weight: bold;
                    font-size: 16px;
                    color: #007AFF;
                    margin-top: 10px;
                }
                .day-section {
                    margin-top: 25px;
                }
                .day-header {
                    background-color: #F5F5F5;
                    padding: 10px 15px;
                    border-radius: 8px;
                    font-weight: semibold;
                    font-size: 16px;
                    margin-bottom: 10px;
                }
                .entry {
                    padding: 8px 15px;
                    border-left: 3px solid #007AFF;
                    margin-left: 15px;
                    margin-bottom: 8px;
                    background-color: #FAFAFA;
                }
                .entry-project {
                    font-weight: bold;
                    font-size: 15px;
                    color: #333;
                }
                .entry-time {
                    font-size: 14px;
                    color: #666;
                    margin-top: 4px;
                }
                .entry-note {
                    font-size: 13px;
                    color: #888;
                    margin-top: 4px;
                    font-style: italic;
                }
                .entry-duration {
                    float: right;
                    font-weight: bold;
                    color: #007AFF;
                    font-size: 15px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>TimeApp - \(L10n.exportTitle)</h1>
                    <div class="header-info">
                        <div><strong>\(L10n.exportPeriod):</strong> \(data.periodLabel)</div>
                        <div><strong>\(L10n.entriesProjectLabel):</strong> \(data.projectLabel)</div>
                        <div class="total">\(data.totalPeriod)</div>
                    </div>
                </div>
        """

        // Adăugare entries pentru fiecare zi
        for group in data.groupedEntries {
            html += """
                <div class="day-section">
                    <div class="day-header">
                        \(group.formattedDate) - \(L10n.exportTotalDay): \(group.formattedTotal)
                    </div>
            """

            for entry in group.entries {
                let projectName = entry.project?.name ?? L10n.timerUnknown
                let timeRange = formatTimeRange(entry)
                let duration = entry.formattedDuration

                html += """
                    <div class="entry">
                        <span class="entry-duration">\(duration)</span>
                        <div class="entry-project">\(projectName)</div>
                        <div class="entry-time">\(timeRange)</div>
                """

                if !entry.note.isEmpty {
                    html += """
                        <div class="entry-note">\(entry.note)</div>
                    """
                }

                html += """
                    </div>
                """
            }

            html += """
                </div>
            """
        }

        html += """
            </div>
        </body>
        </html>
        """

        return html
    }

    /// Formatează intervalul de timp pentru un entry
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
