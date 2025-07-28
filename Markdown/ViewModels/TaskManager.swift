//import Foundation
//import FirebaseFirestore
//import FirebaseAuth
//
//class TaskManager: ObservableObject {
//    
//    @Published var tasks: [TaskItem] = []
//    @Published var isLoading = true // ✅ Add this
//    private var db = Firestore.firestore()
//    private var listenerRegistration: ListenerRegistration?
//    
//    deinit {
//        listenerRegistration?.remove()
//    }
//    
//    func fetchTasks() {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        
//        listenerRegistration?.remove()
//        
//        // The data(as:) method will now automatically fill in the `id` property for us!
//        self.listenerRegistration = db.collection("users").document(userId).collection("tasks").addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            
//            self.tasks = documents.compactMap { queryDocumentSnapshot -> TaskItem? in
//                return try? queryDocumentSnapshot.data(as: TaskItem.self)
//            }
//            self.isLoading = false
//        }
//    }
//    
//    func addTask(task: TaskItem) {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        
//        do {
//            // We don't set the ID here; Firestore does it for us.
//            _ = try db.collection("users").document(userId).collection("tasks").addDocument(from: task)
//        } catch {
//            print("Error adding task: \(error)")
//        }
//    }
//    
//    func updateTask(task: TaskItem) {
//        guard let userId = Auth.auth().currentUser?.uid, let taskId = task.id else { return }
//        
//        // Create a mutable copy of the task to modify it before saving.
//        var taskToUpdate = task
//        
//        // If the task is being marked as complete, set the timestamp.
//        if taskToUpdate.isCompleted {
//            taskToUpdate.completedAt = Date() // Sets it to the current time
//        } else {
//            // If it's being marked incomplete, clear the timestamp.
//            taskToUpdate.completedAt = nil
//        }
//        
//        do {
//            try db.collection("users").document(userId).collection("tasks").document(taskId).setData(from: taskToUpdate)
//        } catch {
//            print("Error updating task: \(error)")
//        }
//    }
//    func fetchCompletedTasks(forLast days: Int, completion: @escaping ([TaskItem]) -> Void) {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            completion([])
//            return
//        }
//        
//        // Calculate the start date (e.g., 7 days ago)
//        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
//        
//        db.collection("users").document(userId).collection("tasks")
//            .whereField("isCompleted", isEqualTo: true)
//            .whereField("completedAt", isGreaterThanOrEqualTo: startDate)
//            .getDocuments { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("Error fetching completed tasks: \(error?.localizedDescription ?? "Unknown error")")
//                    completion([])
//                    return
//                }
//                
//                let completedTasks = documents.compactMap { try? $0.data(as: TaskItem.self) }
//                completion(completedTasks)
//            }
//    }
//
//    // This function saves a WeeklyReview object to Firestore.
//    func saveReview(_ review: WeeklyReview) {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        
//        do {
//            // We will store reviews in a new top-level collection for that user.
//            _ = try db.collection("users").document(userId).collection("weeklyReviews").addDocument(from: review)
//        } catch {
//            print("Error saving review: \(error)")
//        }
//    }
//    func recommendTask(for energy: EnergyLevel) -> TaskItem? {
//        // 1. Get only the tasks that are not yet complete.
//        let incompleteTasks = self.tasks.filter { !$0.isCompleted }
//        
//        var bestTask: TaskItem?
//        var highestScore = -1.0 // Start with a very low score
//
//        // 2. Loop through every incomplete task to score it.
//        for task in incompleteTasks {
//            var score = 0.0
//            
//            // 3. Scoring Rule: Energy Match
//            //    - Perfect match gets a big boost.
//            //    - Mismatch gets a penalty.
//            if task.energyLevel == energy {
//                score += 100.0 // Perfect match
//            } else if energy == .shallow && task.energyLevel == .recharge {
//                score += 25.0 // It's okay to do a recharge task on medium energy
//            } else {
//                score -= 50.0 // Penalize energy mismatch
//            }
//            
//            // 4. Scoring Rule: Urgency
//            //    - Give points for each day closer the due date is.
//            if let dueDate = task.dueDate {
//                let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
//                if daysUntilDue < 1 {
//                    score += 200.0 // Due today or overdue! Very high priority.
//                } else if daysUntilDue < 7 {
//                    score += 50.0 / Double(daysUntilDue) // More points the closer it is
//                }
//            }
//            
//            // 5. Check if this task is the new best one.
//            if score > highestScore {
//                highestScore = score
//                bestTask = task
//            }
//        }
//        
//        return bestTask
//    }
//    func deleteTask(task: TaskItem) {
//        guard let userId = Auth.auth().currentUser?.uid, let taskId = task.id else { return }
//        
//        db.collection("users").document(userId).collection("tasks").document(taskId).delete { error in
//            if let error = error {
//                print("Error removing document: \(error)")
//            } else {
//                print("Document successfully removed!")
//            }
//        }
//    }
//    
//}
import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions

class TaskManager: ObservableObject {
    
    @Published var tasks: [TaskItem] = []
    @Published var isLoading = true // ✅ Add this
    private var db = Firestore.firestore()
    private lazy var functions = Functions.functions(region: "us-east1")
    private var listenerRegistration: ListenerRegistration?
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listenerRegistration?.remove()
        
        // The data(as:) method will now automatically fill in the `id` property for us!
        self.listenerRegistration = db.collection("users").document(userId).collection("tasks").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.tasks = documents.compactMap { queryDocumentSnapshot -> TaskItem? in
                return try? queryDocumentSnapshot.data(as: TaskItem.self)
            }
            self.isLoading = false
        }
    }
    
    func addTask(task: TaskItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            let documentReference = try db.collection("users").document(userId).collection("tasks").addDocument(from: task)
            // ✅ Schedule notification for the newly created task
            var newTask = task
            newTask.id = documentReference.documentID
            NotificationManager.shared.scheduleNotification(for: newTask)
        } catch {
            print("Error adding task: \(error)")
        }
    }
    func updateTask(task: TaskItem) {
        guard let userId = Auth.auth().currentUser?.uid, let taskId = task.id else { return }
        
        // Create a mutable copy of the task to modify it before saving.
        var taskToUpdate = task
        
        // If the task is being marked as complete, set the timestamp.
        if taskToUpdate.isCompleted {
            taskToUpdate.completedAt = Date() // Sets it to the current time
        } else {
            // If it's being marked incomplete, clear the timestamp.
            taskToUpdate.completedAt = nil
        }
        
        do {
                try db.collection("users").document(userId).collection("tasks").document(taskId).setData(from: taskToUpdate)
                // ✅ Re-schedule the notification with the potentially new date
                NotificationManager.shared.scheduleNotification(for: taskToUpdate)
            } catch {
                print("Error updating task: \(error)")
            }
    }
    func fetchCompletedTasks(forLast days: Int, completion: @escaping ([TaskItem]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        // Calculate the start date (e.g., 7 days ago)
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        db.collection("users").document(userId).collection("tasks")
            .whereField("isCompleted", isEqualTo: true)
            .whereField("completedAt", isGreaterThanOrEqualTo: startDate)
            .getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching completed tasks: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                let completedTasks = documents.compactMap { try? $0.data(as: TaskItem.self) }
                completion(completedTasks)
            }
    }

    // This function saves a WeeklyReview object to Firestore.
    func saveReview(_ review: WeeklyReview) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            // We will store reviews in a new top-level collection for that user.
            _ = try db.collection("users").document(userId).collection("weeklyReviews").addDocument(from: review)
        } catch {
            print("Error saving review: \(error)")
        }
    }
    func recommendTask(for energy: EnergyLevel) -> TaskItem? {
        // 1. Get only the tasks that are not yet complete.
        let incompleteTasks = self.tasks.filter { !$0.isCompleted }
        
        var bestTask: TaskItem?
        var highestScore = -1.0 // Start with a very low score

        // 2. Loop through every incomplete task to score it.
        for task in incompleteTasks {
            var score = 0.0
            
            // 3. Scoring Rule: Energy Match
            //    - Perfect match gets a big boost.
            //    - Mismatch gets a penalty.
            if task.energyLevel == energy {
                score += 100.0 // Perfect match
            } else if energy == .shallow && task.energyLevel == .recharge {
                score += 25.0 // It's okay to do a recharge task on medium energy
            } else {
                score -= 50.0 // Penalize energy mismatch
            }
            
            // 4. Scoring Rule: Urgency
            //    - Give points for each day closer the due date is.
            if let dueDate = task.dueDate {
                let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
                if daysUntilDue < 1 {
                    score += 200.0 // Due today or overdue! Very high priority.
                } else if daysUntilDue < 7 {
                    score += 50.0 / Double(daysUntilDue) // More points the closer it is
                }
            }
            
            // 5. Check if this task is the new best one.
            if score > highestScore {
                highestScore = score
                bestTask = task
            }
        }
        
        return bestTask
    }
    func deleteTask(task: TaskItem) {
        guard let userId = Auth.auth().currentUser?.uid, let taskId = task.id else { return }
        
        db.collection("users").document(userId).collection("tasks").document(taskId).delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                // ✅ Cancel any pending notification for the deleted task
                NotificationManager.shared.cancelNotification(for: task)
            }
        }
    }
//    func getMotivation(for task: TaskItem, completion: @escaping (Result<String, Error>) -> Void) {
//            // 1. Prepare the data to send to the cloud function.
//            //    The keys must match what the Python function expects.
//            let taskData: [String: Any] = [
//                "name": task.title,
//                "description": task.description ?? "",
//                "dueDate": task.dueDate?.formatted() ?? "No due date"
//            ]
//            
//            // 2. Call the function by its name ("get_task_motivation" from your main.py).
//            functions.httpsCallable("get_task_motivation").call(taskData) { result, error in
//                if let error = error {
//                    print("Error calling cloud function: \(error)")
//                    completion(.failure(error))
//                    return
//                }
//                
//                // 3. Parse the result to get the motivational text.
//                if let data = result?.data as? [String: Any],
//                   let motivationText = data["motivationText"] as? String {
//                    completion(.success(motivationText))
//                } else {
//                    completion(.failure(NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])))
//                }
//            }
//        }
    func getTaskBreakdown(for task: TaskItem, completion: @escaping (Result<[String], Error>) -> Void) {
        let taskData: [String: Any] = [
            "name": task.title,
            "description": task.description ?? ""
        ]
        
        functions.httpsCallable("get_task_breakdown").call(taskData) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = result?.data as? [String: Any],
               let steps = data["steps"] as? [String] {
                completion(.success(steps))
            } else {
                completion(.failure(NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])))
            }
        }
    }
    }
    

