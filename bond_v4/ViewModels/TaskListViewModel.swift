////
////  TaskListViewModel.swift
////  bond_v4
////
////  Created by CJ Sanchez on 7/18/25.
////
//
//import Foundation
//
//struct TaskTree: Identifiable {
//    let parent: TaskItem
//    let children: [TaskItem]
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
//        // --- UPDATED TO CALL THE NEW FUNCTION ---
//        apiService.fetchAllTasks { [weak self] result in
//            guard let self = self else { return }
//            self.isLoading = false
//            
//            switch result {
//            case .success(let allTasks):
//                // The service now returns a simple array, ready to be grouped
//                self.groupTasks(allTasks)
//                
//            case .failure(let error):
//                self.errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
//            }
//        }
//    }
//    
//    private func groupTasks(_ tasks: [TaskItem]) {
//        let childrenByParentId = Dictionary(grouping: tasks.filter { $0.parent_id != nil }, by: { $0.parent_id! })
//        let rootTasks = tasks.filter { $0.parent_id == nil }
//        
//        self.taskTrees = rootTasks.map { parent in
//            let children = childrenByParentId[parent.task_id] ?? []
//            return TaskTree(parent: parent, children: children)
//        }
//    }
//}
import Foundation

struct TaskTree: Identifiable {
    var parent: TaskItem // Changed to var to allow mutation
    var children: [TaskItem] // Changed to var to allow mutation
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
        
        apiService.fetchAllTasks { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let allTasks):
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

    // --- UPDATED FUNCTION TO TOGGLE COMPLETION WITH CASCADING LOGIC ---
    func toggleCompletion(for task: TaskItem) {
        // First, find the index of the parent tree this task belongs to.
        guard let treeIndex = taskTrees.firstIndex(where: { $0.parent.id == task.parent_id || $0.parent.id == task.id }) else { return }
        
        let newStatus = !task.is_complete
        
        // Store original states for potential reversal on API failure
        let originalParentStatus = taskTrees[treeIndex].parent.is_complete
        let originalChildrenStatus = taskTrees[treeIndex].children.map { $0.is_complete }

        // --- Optimistically update the UI first for a snappy user experience ---
        if task.parent_id == nil {
            // This is a parent task. Update the parent AND all its children.
            taskTrees[treeIndex].parent.is_complete = newStatus
            for i in 0..<taskTrees[treeIndex].children.count {
                taskTrees[treeIndex].children[i].is_complete = newStatus
            }
        } else {
            // This is a child task. Just update the child.
            guard let childIndex = taskTrees[treeIndex].children.firstIndex(where: { $0.id == task.id }) else { return }
            taskTrees[treeIndex].children[childIndex].is_complete = newStatus
        }
        
        // Call the API to update the backend.
        apiService.updateTaskStatus(taskID: task.id, isComplete: newStatus) { [weak self] result in
            if case .failure(let error) = result {
                // If the API call fails, revert the change in the UI and show an error.
                print("Failed to update task: \(error.localizedDescription)")
                self?.errorMessage = "Failed to sync task. Please try again."
                
                // Revert the toggle using the stored original states
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.taskTrees[treeIndex].parent.is_complete = originalParentStatus
                    for i in 0..<originalChildrenStatus.count {
                        self.taskTrees[treeIndex].children[i].is_complete = originalChildrenStatus[i]
                    }
                }
            }
        }
    }
}
