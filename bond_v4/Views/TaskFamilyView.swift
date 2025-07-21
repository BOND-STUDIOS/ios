//////
//////  TaskFamilyView.swift
//////  bond_v4
//////
//////  Created by CJ Sanchez on 7/18/25.
//////
////
//
//import SwiftUI
//
//struct TaskFamilyView: View {
//    let tree: TaskTree
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                Text("Main Task")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .padding(.horizontal)
//                
//                // Display the parent task using your existing TaskCardView
//                TaskCardView(task: tree.parent)
//                
//                // Display the sub-tasks if any exist
//                if !tree.children.isEmpty {
//                    Text("Sub-tasks")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal)
//                        .padding(.top)
//                    
//                    ForEach(tree.children) { childTask in
//                        TaskCardView(task: childTask)
//                    }
//                }
//                
//                Spacer()
//            }
//            .padding()
//        }
//    }
//}
//
import SwiftUI

struct TaskFamilyView: View {
    @EnvironmentObject var viewModel: TaskListViewModel
    let tree: TaskTree

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Parent Task Row
            TaskRowView(task: tree.parent)

            // Children Tasks Section
            if !tree.children.isEmpty {
                Divider().padding(.leading, 20)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(tree.children) { child in
                        TaskRowView(task: child)
                            .padding(.leading, 20) // Indent subtasks
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    // --- Private Sub-view for a single task row ---
    // This makes the code reusable and clean without needing a separate file.
    internal struct TaskRowView: View {
        @EnvironmentObject var viewModel: TaskListViewModel
        let task: TaskItem

        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                // Tappable Checkmark
                Image(systemName: task.is_complete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.is_complete ? .green : .accentColor)
                    .font(.title2)
                    .onTapGesture {
                        viewModel.toggleCompletion(for: task)
                    }

                VStack(alignment: .leading) {
                    Text(task.task_description)
                        .font(.headline)
                        .strikethrough(task.is_complete, color: .secondary)
                    
                    if let dueDate = task.due_date {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(dueDate)
                            if let dueTime = task.due_time {
                                Text("at \(dueTime)")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .opacity(task.is_complete ? 0.5 : 1.0)
                
                Spacer()
            }
            .padding()
        }
    }
}
