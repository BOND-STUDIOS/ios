//
//  JournalView.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/11/25.
//

import SwiftUI

struct JournalView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var journalingService = JournalingService()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                if journalingService.journalEntries.isEmpty {
                    Text("No journal entries found.")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    List(journalingService.journalEntries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.formattedDate)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(entry.content)
                                .lineLimit(3)
                        }
                        .listRowBackground(Color.gray.opacity(0.1))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Journal")
            .onAppear {
                fetchEntries()
            }
            .alert("Error", isPresented: .constant(journalingService.errorMessage != nil), actions: {
                Button("OK") { journalingService.errorMessage = nil }
            }, message: {
                Text(journalingService.errorMessage ?? "An unknown error occurred.")
            })
        }
        .foregroundColor(.white)
    }
    
    private func fetchEntries() {
        print("JournalView: fetchEntries() was called.")
        guard let idToken = authViewModel.idToken else {
            print("JournalView: Failed to get idToken.")

            journalingService.errorMessage = "You are not signed in."
            return
        }
        Task {
            await journalingService.fetchJournalEntries(idToken: idToken)
        }
    }
}
