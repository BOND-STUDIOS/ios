import Foundation

@MainActor
class ReportsService: ObservableObject {
    @Published var reports: [DailyReport] = []
    @Published var errorMessage: String?

    // IMPORTANT: Use the same full Invoke URL as your other services
    private let baseURL = "https://81igm8jtr1.execute-api.us-east-1.amazonaws.com"

    func fetchReports(idToken: String) async {
        print("ReportsService: Attempting to fetch reports.")
        guard let url = URL(string: "\(baseURL)/reports") else {
            self.errorMessage = "Invalid URL for reports."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                self.errorMessage = "Server returned an error fetching reports: \(statusCode)"
                return
            }

            let decoder = JSONDecoder()
            self.reports = try decoder.decode([DailyReport].self, from: data)
            print("Successfully decoded \(self.reports.count) reports.")

        } catch {
            self.errorMessage = "Failed to fetch or decode reports: \(error.localizedDescription)"
            print("❌ ReportsService error: \(error)")
        }
    }
}
