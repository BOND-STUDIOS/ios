//
//  TaskView.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/18/25.
//
//import SwiftUI
//struct TaskView: View {
//    @StateObject private var viewModel = TaskViewModel()
//
//        var body: some View {
//            NavigationStack {
//                VStack {
//                    // Display Area for Agent's Response
//                    Text(viewModel.agentResponse)
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    // List of newly created tasks
//                    ScrollView {
//                        VStack(spacing: 10) {
//                            // --- THIS IS THE FIX ---
//                            // Because TaskItem is Identifiable, we don't need `id: \.self`.
//                            // SwiftUI will automatically use the `id` property.
//                            ForEach(viewModel.createdTasks) { task in
//                                TaskCardView(task: task)
//                            }
//                        }
//                    }
//
//                    Spacer()
//
//                    // Error Message Display
//                    if let errorMessage = viewModel.errorMessage {
//                        Text(errorMessage)
//                            .foregroundColor(.red)
//                            .font(.caption)
//                            .padding(.bottom, 5)
//                    }
//
//                    // Input Area
//                    HStack {
//                        TextField("Ask me to create a task...", text: $viewModel.userInput)
//                            .textFieldStyle(.roundedBorder)
//                            .onSubmit(viewModel.sendRequest)
//
//                        if viewModel.isLoading {
//                            ProgressView().padding(.horizontal, 10)
//                        } else {
//                            Button(action: viewModel.sendRequest) {
//                                Image(systemName: "arrow.up.circle.fill").font(.title)
//                            }
//                            .disabled(viewModel.userInput.isEmpty)
//                        }
//                    }
//                }
//                .padding()
//                .navigationTitle("ADHD Task Agent")
//            }
//        }
//    }
import SwiftUI

struct TaskView: View {
    @StateObject private var viewModel = TaskViewModel()
    @FocusState private var isTextFieldFocused: Bool // 1. Add FocusState

    var body: some View {
        NavigationStack {
            VStack {
                // Display Area for Agent's Response
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.agentResponse)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray5))
                            .cornerRadius(12)

                        // List of newly created tasks in this session
                        ForEach(viewModel.createdTasks) { task in
                            // We can reuse the TaskFamilyView's sub-view for a consistent look
                            TaskFamilyView.TaskRowView(task: task)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                }

                Spacer()

                // Error Message Display
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom, 5)
                }

                // Input Area
                HStack {
                    TextField("Ask me to create a task...", text: $viewModel.userInput)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused) // 2. Bind to TextField
                        .onSubmit {
                            if !viewModel.userInput.isEmpty {
                                viewModel.sendRequest()
                            }
                        }

                    if viewModel.isLoading {
                        ProgressView().padding(.horizontal, 10)
                    } else {
                        Button(action: {
                            viewModel.sendRequest()
                            isTextFieldFocused = false // 3. Dismiss keyboard on tap
                        }) {
                            Image(systemName: "arrow.up.circle.fill").font(.title)
                        }
                        .disabled(viewModel.userInput.isEmpty)
                    }
                }
            }
            .padding()
            .navigationTitle("Create Task")
            .onTapGesture {
                // Allow dismissing keyboard by tapping outside the textfield
                isTextFieldFocused = false
            }
            // We need to provide a TaskListViewModel for the TaskRowView, even if it's empty
            .environmentObject(TaskListViewModel())
        }
    }
}
