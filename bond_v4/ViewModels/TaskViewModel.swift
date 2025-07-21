//
//  TaskViewModel.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/18/25.
//
//import SwiftUI
//import Foundation
//
//@MainActor // Ensures UI updates happen on the main thread
//class TaskViewModel: ObservableObject {
//        @Published var userInput: String = ""
//        @Published var agentResponse: String = "Hi! How can I help you organize your day?"
//        @Published var isLoading: Bool = false
//        @Published var errorMessage: String?
//        
//        // This array will hold the tasks to be displayed in the UI
//        @Published var createdTasks: [TaskItem] = []
//
//        private let apiService = TaskAPIService()
//
//        func sendRequest() {
//            guard !userInput.isEmpty else { return }
//            
//            isLoading = true
//            errorMessage = nil
//            let messageToSend = userInput
//            userInput = ""
//
//            apiService.sendMessage(messageToSend) { [weak self] result in
//                guard let self = self else { return }
//                self.isLoading = false
//                
//                switch result {
//                case .success(let response):
//                    // Update the conversational response
//                    self.agentResponse = response.response
//                    // Add the new tasks to our list
//                    self.createdTasks.append(contentsOf: response.tasks)
//                    
//                case .failure(let error):
//                    self.errorMessage = "Error: \(error.localizedDescription)"
//                    self.agentResponse = "Sorry, something went wrong."
//                }
//            }
//        }
//    }
import Foundation

@MainActor
class TaskViewModel: ObservableObject {
    @Published var userInput: String = ""
    @Published var agentResponse: String = "Hi! How can I help you organize your day?"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // This array will hold the tasks created in this session to be displayed
    @Published var createdTasks: [TaskItem] = []

    private let apiService = TaskAPIService()

    func sendRequest() {
        guard !userInput.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        let messageToSend = userInput
        userInput = ""

        apiService.sendMessage(messageToSend) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.agentResponse = response.response
                // Add any newly created tasks to the local list for display
                self.createdTasks.append(contentsOf: response.tasks)
                
            case .failure(let error):
                self.errorMessage = "Error: \(error.localizedDescription)"
                self.agentResponse = "Sorry, something went wrong."
            }
        }
    }
}
