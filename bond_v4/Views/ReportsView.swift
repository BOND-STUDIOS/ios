//
//  DailyReportView.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/14/25.
//

import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var reportsService = ReportsService()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                if reportsService.reports.isEmpty && reportsService.errorMessage == nil {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let errorMessage = reportsService.errorMessage {
                     Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if reportsService.reports.isEmpty {
                    Text("No reports found.")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    List {
                        ForEach(reportsService.reports) { report in
                            NavigationLink(destination: ReportDetailView(report: report)) {
                                VStack(alignment: .leading) {
                                    Text(report.report_date)
                                        .font(.headline)
                                    Text("Status: \(report.status)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.1))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Daily Reports")
            .onAppear {
                fetchReports()
            }
        }
        .foregroundColor(.white)
    }
    
    private func fetchReports() {
        guard let idToken = authViewModel.idToken else {
            reportsService.errorMessage = "You are not signed in."
            return
        }
        Task {
            await reportsService.fetchReports(idToken: idToken)
        }
    }
}

