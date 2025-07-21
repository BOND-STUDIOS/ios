//
//  TaskCardView.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/18/25.
//
//import SwiftUI
//
//struct TaskCardView: View {
//    let task: TaskItem
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Image(systemName: task.is_complete ? "checkmark.circle.fill" : "circle")
//                    .foregroundColor(task.is_complete ? .green : .secondary)
//                Text(task.task_description)
//                    .font(.headline)
//                    .strikethrough(task.is_complete)
//            }
//
//            // Display due date and time if they exist
//            if let dueDate = task.due_date {
//                HStack {
//                    Image(systemName: "calendar")
//                        .foregroundColor(.secondary)
//                    Text("Due: \(dueDate)")
//                    if let dueTime = task.due_time {
//                        Text("at \(dueTime)")
//                    }
//                }
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//            }
//            
//            // Display parent task ID if it's a sub-task
//            if let parentId = task.parent_id {
//                 HStack {
//                    Image(systemName: "arrow.turn.down.right")
//                        .foregroundColor(.secondary)
//                    Text("Sub-task of: \(parentId.prefix(8))...")
//                 }
//                 .font(.caption)
//                 .foregroundColor(.gray)
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//    }
//}
import SwiftUI

struct TaskCardView: View {
    // This view now needs access to the ViewModel to perform actions
    @EnvironmentObject var viewModel: TaskListViewModel
    let task: TaskItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // Make the checkmark tappable
                Image(systemName: task.is_complete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.is_complete ? .green : .secondary)
                    .font(.title2) // Make it a bit bigger for tapping
                    .padding(.top, 2)
                    .onTapGesture {
                        viewModel.toggleCompletion(for: task)
                    }
                
                VStack(alignment: .leading) {
                    Text(task.task_description)
                        .font(.headline)
                        .strikethrough(task.is_complete, color: .secondary)
                        .opacity(task.is_complete ? 0.6 : 1.0)

                    // Display due date and time if they exist
                    if let dueDate = task.due_date {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Due: \(dueDate)")
                            if let dueTime = task.due_time {
                                Text("at \(dueTime)")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                    }
                    
                    // Display parent task ID if it's a sub-task
                    if let parentId = task.parent_id {
                         HStack {
                            Image(systemName: "arrow.turn.down.right")
                            Text("Sub-task of: \(parentId.prefix(8))...")
                         }
                         .font(.caption)
                         .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
