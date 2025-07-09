//
//  AgentAPI.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/8/25.
//

import Foundation


class AgentAPI: ObservableObject{
    
    func sendPrompt(_ prompt: String, using authViewModel: AuthenticationViewModel, audioPlayer: AudioPlayerService) async {
            // 1. Get the token directly from the authViewModel
            guard let idToken = authViewModel.idToken else {
                print("Not signed in or token not available.")
                return
            }

            do {
                // 2. Call your network handling function
                print("Sending request with token...")
                let response = try await self.handleSend(prompt: prompt, idToken: idToken)
                print("✅ Success! Lambda response: \(response.text_response)")
                await audioPlayer.play(base64: response.audio_response_base64)

            } catch {
                print("❌ Error making API call: \(error.localizedDescription)")
            }
        }

    func handleSend(prompt: String, idToken: String) async throws -> ResponsePayload{
        guard let url = URL(string: "https://cvu9z4rmjf.execute-api.us-east-1.amazonaws.com/prod/ask") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        
        let requestBody = SendPayload(prompt: prompt)
        request.httpBody = try JSONEncoder().encode(requestBody)

        // 4. Perform the request and get data
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                // You can print the raw data here to see error messages from the server
                print(String(data: data, encoding: .utf8) ?? "No response body")
                throw NetworkError.serverError(statusCode: statusCode)
            }

            // 6. Decode the JSON response from the server

        do {
            let decodedResponse = try JSONDecoder().decode(ResponsePayload.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError
        }
        
        
        
    }
    
    
}
