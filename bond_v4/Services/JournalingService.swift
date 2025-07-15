//
//  JournalingService.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/11/25.
//

import Foundation

@MainActor
class JournalingService: ObservableObject {
    @Published var journalEntries: [JournalEntry] = []
    @Published var errorMessage: String?

    // NOTE: This should be your actual API Gateway URL
    private let baseURL = "https://81igm8jtr1.execute-api.us-east-1.amazonaws.com"

    func fetchJournalEntries(idToken: String) async {
        print("JournalingService: Attempting to fetch journals from API.")

        guard let url = URL(string: "\(baseURL)/journals") else {
            self.errorMessage = "Invalid URL for journals."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            // ✅ --- ADD THESE PRINT STATEMENTS ---
            if let httpResponse = response as? HTTPURLResponse {
                print("JournalingService: Received HTTP status code: \(httpResponse.statusCode)")
            }
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("JournalingService: Received raw JSON string: \(rawJSON)")
            }
            // ✅ --- END ADDITION ---

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {

                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                self.errorMessage = "Server returned an error: \(statusCode)"
                
                return
            }

            let decoder = JSONDecoder()
            self.journalEntries = try decoder.decode([JournalEntry].self, from: data)

        } catch {
            print("JournalingService: ❌ Decoding failed or network error: \(error)")

            self.errorMessage = "Failed to fetch or decode journal entries: \(error.localizedDescription)"
            print("❌ Journal fetch error: \(error)")
        }
    }
}
