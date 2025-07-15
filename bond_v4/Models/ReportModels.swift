//
//  ReportModels.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/14/25.
//

// Create a new file named ReportModels.swift

import Foundation

// Represents the overall structure of a report fetched from the API
struct DailyReport: Codable, Identifiable, Hashable {
    let user_id: String
    let report_date: String
    let report_content: ReportContent
    let status: String
    let generated_at: String
    
    // Use report_date for Identifiable conformance since it's unique per user
    var id: String {
        return report_date
    }
}

// Represents the nested 'report_content' object
struct ReportContent: Codable, Hashable {
    let daily_report: [ReportTopic]
}

// Represents a single topic within the report
struct ReportTopic: Codable, Hashable, Identifiable {
    let topic_name: String
    let summary: String

    // Provide an id for ForEach loops
    var id: String { topic_name }
}


// Create a new file named ReportsService.swift

