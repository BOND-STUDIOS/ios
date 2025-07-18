//
//  TaskAPIModel.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/18/25.
//

//import Foundation
//
//// Structure for the request body we will send to the API
//struct APIRequest: Codable {
//    let message: String
//}
//
//// Structure for the response body we expect back from the API
//struct APIResponse: Codable {
//    let response: String
//}

//struct TaskItem: Codable, Identifiable, Hashable {
//    let task_id: String
//    let task_description: String
//    var is_complete: Bool
//    let created_at: String
//    let due_date: String?
//    let due_time: String?
//    let parent_id: String?
//
//    // Conform to Identifiable for easy use in SwiftUI Lists
//    var id: String { task_id }
//}
//
//struct APIResponse: Codable {
//    let response: String
//    let tasks: [TaskItem]
//}
//
//// Structure for the request body (this remains the same)
//struct APIRequest: Codable {
//    let message: String
//}
import Foundation

struct TaskItem: Codable, Identifiable, Hashable {
    let task_id: String
    let task_description: String
    var is_complete: Bool
    let created_at: String
    let due_date: String?
    let due_time: String?
    let parent_id: String?

    var id: String { task_id }
}

struct APIResponse: Codable {
    let response: String
    // This key is used when creating tasks
    let tasks: [TaskItem]
    // This new key is used when listing all tasks
    let all_tasks: [TaskItem]?
}

struct APIRequest: Codable {
    let message: String
}
struct TaskListResponse: Codable {
    let tasks: [TaskItem]
}
