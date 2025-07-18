////
////  TaskFamilyView.swift
////  bond_v4
////
////  Created by CJ Sanchez on 7/18/25.
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
//                // Display the parent task
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
import SwiftUI

struct TaskFamilyView: View {
    let tree: TaskTree
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Main Task")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Display the parent task using your existing TaskCardView
                TaskCardView(task: tree.parent)
                
                // Display the sub-tasks if any exist
                if !tree.children.isEmpty {
                    Text("Sub-tasks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    ForEach(tree.children) { childTask in
                        TaskCardView(task: childTask)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
