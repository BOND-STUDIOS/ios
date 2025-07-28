//
//  TaskAssistantView.swift
//  Markdown
//
//  Created by CJ Sanchez on 7/23/25.
//

import SwiftUI

struct TaskAssistantView: View {
    // Managers and the selected task are passed in
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var journeyManager: JourneyManager
    let task: TaskItem

    // State for this view
    @State private var isLoadingMotivation = false
    @State private var motivationText: String?
    
    @State private var isLoadingBreakdown = false
    @State private var breakdownSteps: [String]?
    
    // We can add state for the breakdown later
    // @State private var breakdownSteps: [String]?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // --- Task Details ---
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.largeTitle).bold()
                        
                        if let description = task.description, !description.isEmpty {
                            Text(description)
                                .foregroundColor(.secondary)
                        }
                        
                        if let dueDate = task.dueDate {
                            Label(dueDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // --- AI Motivation Section ---
//                    VStack(alignment: .leading) {
//                        Text("AI MOTIVATION")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        
//                        if isLoadingMotivation {
//                            ProgressView()
//                                .frame(maxWidth: .infinity)
//                        } else if let motivation = motivationText {
//                            Text(motivation)
//                        }
//                    }
//                    if !isLoadingMotivation && motivationText != nil {
//                                            Button("Walk me through this") {
//                                                fetchBreakdown()
//                                            }
//                                            .buttonStyle(.bordered)
//                                            
//                                            if isLoadingBreakdown {
//                                                ProgressView()
//                                            } else if let steps = breakdownSteps {
//                                                ForEach(steps, id: \.self) { step in
//                                                    Label(step, systemImage: "arrow.right.circle")
//                                                        .padding(.top, 4)
//                                                }
//                                            }
//                                        }
//                    if !isLoadingMotivation && motivationText != nil {
                                            Button("Walk me through this") {
                                                fetchBreakdown()
                                            }
                                            .buttonStyle(.bordered)
                                            
                                            if isLoadingBreakdown {
                                                ProgressView()
                                            } else if let steps = breakdownSteps {
                                                ForEach(steps, id: \.self) { step in
                                                    Label(step, systemImage: "arrow.right.circle")
                                                        .padding(.top, 4)
                                                }
                                            }
//                                        }
                }
                .padding()
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
//            .onAppear(perform: fetchMotivation)
        }
    }
    
    // This function calls the TaskManager to get the AI response
//    private func fetchMotivation() {
//        isLoadingMotivation = true
//        taskManager.getMotivation(for: task) { result in
//            isLoadingMotivation = false
//            switch result {
//            case .success(let text):
//                self.motivationText = text
//            case .failure(let error):
//                self.motivationText = "Sorry, I couldn't get a suggestion. Error: \(error.localizedDescription)"
//            }
//        }
//    }
    private func fetchBreakdown() {
            isLoadingBreakdown = true
            taskManager.getTaskBreakdown(for: task) { result in
                isLoadingBreakdown = false
                switch result {
                case .success(let steps):
                    self.breakdownSteps = steps
                case .failure(let error):
                    // You could display this error in the UI
                    print("Breakdown error: \(error.localizedDescription)")
                }
            }
        }
}
