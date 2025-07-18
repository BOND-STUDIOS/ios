////
////  TaskAPIService.swift
////  bond_v4
////
////  Created by CJ Sanchez on 7/18/25.
////
//
//// APIService.swift
//
//import Foundation
//
//class TaskAPIService {
//    private let apiURL = URL(string: "https://4mkyocbdzb.execute-api.us-east-1.amazonaws.com/default/taskLambda")!
//
//    func sendMessage(_ message: String, completion: @escaping (Result<APIResponse, Error>) -> Void) {
//        var request = URLRequest(url: apiURL)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let requestBody = APIRequest(message: message)
//
//        do {
//            request.httpBody = try JSONEncoder().encode(requestBody)
//        } catch {
//            completion(.failure(error))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//
//                guard let data = data else {
//                    let noDataError = NSError(domain: "APIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
//                    completion(.failure(noDataError))
//                    return
//                }
//                
//                // Attempt to print the raw data as a string for debugging
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("Received JSON: \(jsonString)")
//                }
//
//                do {
//                    // Decode the full APIResponse object
//                    let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
//                    completion(.success(apiResponse))
//                } catch {
//                    print("JSON Decoding Error: \(error)")
//                    completion(.failure(error))
//                }
//            }
//        }
//        task.resume()
//    }
//}

import Foundation

class TaskAPIService {
    private let apiURL = URL(string: "https://4mkyocbdzb.execute-api.us-east-1.amazonaws.com/default/taskLambda")!
    
    // This function still talks to the agent for creating tasks
    func sendMessage(_ message: String, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = APIRequest(message: message)
        request.httpBody = try? JSONEncoder().encode(requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    let noDataError = NSError(domain: "APIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(noDataError))
                    return
                }
                
                do {
                    let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(apiResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // --- NEW, FAST FUNCTION ---
    // This function bypasses the agent for high performance listing.
    func fetchAllTasks(completion: @escaping (Result<[TaskItem], Error>) -> Void) {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send the "action" key to trigger the fast path in our Lambda
        let requestBody = ["action": "list_tasks"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    let noDataError = NSError(domain: "APIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(noDataError))
                    return
                }
                do {
                    // Decode the new, simpler TaskListResponse
                    let taskListResponse = try JSONDecoder().decode(TaskListResponse.self, from: data)
                    completion(.success(taskListResponse.tasks))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
