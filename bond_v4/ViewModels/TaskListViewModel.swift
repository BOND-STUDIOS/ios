//
//  TaskListViewModel.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/18/25.
//

//import Foundation
//
//// A helper struct to hold a parent task and its children together
//struct TaskTree: Identifiable {
//    let parent: TaskItem
//    let children: [TaskItem]
//    
//    var id: String { parent.id }
//}
//
//@MainActor
//class TaskListViewModel: ObservableObject {
//    @Published var taskTrees: [TaskTree] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    private let apiService = TaskAPIService()
//    
//    func fetchAllTasks() {
//        isLoading = true
//        errorMessage = nil
//        
//        // Ask the agent to list the tasks
//        apiService.sendMessage("list all my tasks") { [weak self] result in
//            guard let self = self else { return }
//            self.isLoading = false
//            
//            switch result {
//            case .success(let response):
//                // The API now returns tasks in the `all_tasks` field for this command
//                guard let allTasks = response.all_tasks else {
//                    self.errorMessage = "No tasks found in the response."
//                    return
//                }
//                self.groupTasks(allTasks)
//                
//            case .failure(let error):
//                self.errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
//            }
//        }
//    }
//    
//    // This is the core logic to organize the flat list from the database into a hierarchy
//    private func groupTasks(_ tasks: [TaskItem]) {
//        // Create a dictionary to easily look up children by their parent's ID
//        let childrenByParentId = Dictionary(grouping: tasks.filter { $0.parent_id != nil }, by: { $0.parent_id! })
//        
//        // Find all the root tasks (tasks that have no parent)
//        let rootTasks = tasks.filter { $0.parent_id == nil }
//        
//        // Build the final array of TaskTree objects
//        self.taskTrees = rootTasks.map { parent in
//            // Find the children for the current parent, or use an empty array if there are none
//            let children = childrenByParentId[parent.task_id] ?? []
//            return TaskTree(parent: parent, children: children)
//        }
//    }
//}
import Foundation

struct TaskTree: Identifiable {
    let parent: TaskItem
    let children: [TaskItem]
    var id: String { parent.id }
}

@MainActor
class TaskListViewModel: ObservableObject {
    @Published var taskTrees: [TaskTree] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = TaskAPIService()
    
    func fetchAllTasks() {
        isLoading = true
        errorMessage = nil
        
        // --- UPDATED TO CALL THE NEW FUNCTION ---
        apiService.fetchAllTasks { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let allTasks):
                // The service now returns a simple array, ready to be grouped
                self.groupTasks(allTasks)
                
            case .failure(let error):
                self.errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
            }
        }
    }
    
    private func groupTasks(_ tasks: [TaskItem]) {
        let childrenByParentId = Dictionary(grouping: tasks.filter { $0.parent_id != nil }, by: { $0.parent_id! })
        let rootTasks = tasks.filter { $0.parent_id == nil }
        
        self.taskTrees = rootTasks.map { parent in
            let children = childrenByParentId[parent.task_id] ?? []
            return TaskTree(parent: parent, children: children)
        }
    }
}
