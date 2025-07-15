//
//  ReportDetailView.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/14/25.
//

// Create a new file named ReportDetailView.swift

import SwiftUI

struct ReportDetailView: View {
    let report: DailyReport
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                ForEach(report.report_content.daily_report) { topic in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(topic.topic_name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(topic.summary)
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineSpacing(5)
                    }
                    .padding(.bottom, 15)
                }
            }
            .padding()
        }
        .navigationTitle(report.report_date)
        .background(Color.black.ignoresSafeArea())
    }
}
