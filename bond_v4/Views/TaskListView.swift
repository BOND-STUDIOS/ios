//
//  TaskListView.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/18/25.
//

//import SwiftUI
//
//struct TaskListView: View {
//    @StateObject private var viewModel = TaskListViewModel()
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if viewModel.isLoading {
//                    ProgressView("Loading your tasks...")
//                } else if let errorMessage = viewModel.errorMessage {
//                    Text(errorMessage)
//                        .foregroundColor(.red)
//                        .padding()
//                } else if viewModel.taskTrees.isEmpty {
//                    Text("You have no tasks yet. Go to the 'Create' tab to add some!")
//                        .multilineTextAlignment(.center)
//                        .padding()
//                } else {
//                    // This TabView creates the paged, horizontal scrolling effect
//                    TabView {
//                        ForEach(viewModel.taskTrees) { tree in
//                            TaskFamilyView(tree: tree)
//                        }
//                    }
//                    .tabViewStyle(.page(indexDisplayMode: .automatic))
//                    .indexViewStyle(.page(backgroundDisplayMode: .always))
//                }
//            }
//            .navigationTitle("My Tasks")
//            .toolbar {
//                // Add a refresh button
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        viewModel.fetchAllTasks()
//                    }) {
//                        Image(systemName: "arrow.clockwise")
//                    }
//                }
//            }
//            .onAppear {
//                // Fetch tasks when the view first appears
//                viewModel.fetchAllTasks()
//            }
//        }
//    }
//}
import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading your tasks...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.taskTrees.isEmpty {
                    Text("You have no tasks yet. Go to the 'Create' tab to add some!")
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    // This TabView creates the paged, horizontal scrolling effect
                    TabView {
                        ForEach(viewModel.taskTrees) { tree in
                            TaskFamilyView(tree: tree)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                // Add a refresh button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.fetchAllTasks()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                // Fetch tasks when the view first appears, but only if the list is empty
                if viewModel.taskTrees.isEmpty {
                    viewModel.fetchAllTasks()
                }
            }
        }
    }
}
