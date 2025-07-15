////
////  AgentAPI.swift
////  bond_v4
////
////  Created by CJ Sanchez on 7/8/25.
////
//
//import Foundation
//
//@MainActor
//class AgentAPI: ObservableObject{
//    @Published var errorMessage: String?
//    @Published private(set) var isProcessing = false
//    private let authViewModel: AuthenticationViewModel
//    private let audioPlayer: AudioPlayerService
//    
//    init(authViewModel: AuthenticationViewModel, audioPlayer: AudioPlayerService) {
//        self.authViewModel = authViewModel
//        self.audioPlayer = audioPlayer
//    }
//    
//    func sendPrompt(_ prompt: String) async {
//        // 1. Get the token directly from the authViewModel
//        self.errorMessage = nil
//        isProcessing = true
//        defer { isProcessing = false }
//        guard let idToken = authViewModel.idToken else {
//            self.errorMessage = "You are not signed in."
//            print("Not signed in or token not available.")
//            return
//        }
//
//        do {
//            // 2. Call your network handling function
//            print("Sending request with token...")
//            let response = try await self.handleSend(prompt: prompt, idToken: idToken)
//            print("✅ Success! Lambda response: \(response.text_response)")
//            await audioPlayer.play(base64: response.audio_response_base64)
//
//        } catch {
//            print("❌ Error making API call: \(error.localizedDescription)")
//            self.errorMessage = error.localizedDescription
//        }
//    }
//
//    func handleSend(prompt: String, idToken: String) async throws -> ResponsePayload{
//        guard let url = URL(string: "https://cvu9z4rmjf.execute-api.us-east-1.amazonaws.com/prod/ask") else {
//            throw NetworkError.invalidURL
//        }
//        var request = URLRequest(url: url)
//        
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
//        
//        
//        
//        let requestBody = SendPayload(prompt: prompt)
//        request.httpBody = try JSONEncoder().encode(requestBody)
//
//        // 4. Perform the request and get data
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
//                // You can print the raw data here to see error messages from the server
//                print(String(data: data, encoding: .utf8) ?? "No response body")
//                throw NetworkError.serverError(statusCode: statusCode)
//            }
//
//            // 6. Decode the JSON response from the server
//
//        do {
//            let decodedResponse = try JSONDecoder().decode(ResponsePayload.self, from: data)
//            return decodedResponse
//        } catch {
//            throw NetworkError.decodingError
//        }
//        
//        
//        
//    }
//    
//    
//}
// In AgentAPI.swift

import Foundation

// Note: This code assumes you have APIModels.swift with StreamedEvent,
// SendPayload, and NetworkError defined as we discussed.

@MainActor
class AgentAPI: ObservableObject {
    
    @Published var errorMessage: String?

    /// Opens a streaming connection to the Lambda function and returns an AsyncStream of events.
    /// - Parameters:
    ///   - prompt: The user's text prompt.
    ///   - idToken: The user's Google ID Token for authentication.
    /// - Returns: An asynchronous stream of StreamedEvent objects.
    func streamPrompt(_ prompt: String, idToken: String) -> AsyncThrowingStream<StreamedEvent, Error> {
        // Clear any previous error message when a new request starts
        self.errorMessage = nil
        
        // Use the specific Function URL or API Gateway endpoint for your streaming backend
        guard let url = URL(string: "https://81igm8jtr1.execute-api.us-east-1.amazonaws.com/ask") else {
            // If the URL is invalid, return a stream that immediately fails
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: NetworkError.invalidURL)
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue  ("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        // Encode the outgoing request body
        request.httpBody = try? JSONEncoder().encode(SendPayload(prompt: prompt))
        
        // Return the AsyncThrowingStream that performs the network call
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500)
                    }

                    // Process the stream line by line as data arrives
                    for try await line in bytes.lines {
                        // Server-Sent Events are formatted as "data: { ...JSON... }"
                        if line.hasPrefix("data: ") {
                            // Extract the JSON string part
                            let jsonString = line.dropFirst(6)
                            guard let data = jsonString.data(using: .utf8) else { continue }
                            
                            do {
                                // Decode the JSON into our StreamedEvent struct
                                let event = try JSONDecoder().decode(StreamedEvent.self, from: data)
                                // Yield the event to the consumer (your View)
                                continuation.yield(event)
                            } catch {
                                // This handles cases where a single line of JSON is malformed
                                print("Decoding error for a single event: \(error)")
                            }
                        }
                    }
                    // Signal that the stream has finished successfully
                    continuation.finish()
                } catch {
                    // If the entire request fails, finish the stream with an error
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
