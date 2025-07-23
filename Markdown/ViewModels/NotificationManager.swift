//
//  NotificationManager.swift
//  Markdown
//
//  Created by CJ Sanchez on 7/23/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    // Create a "singleton" instance so we can access it from anywhere in our app.
    static let shared = NotificationManager()
    
    // 1. Function to request permission from the user.
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            } else if success {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    // 2. Function to schedule a notification for a specific task.
    func scheduleNotification(for task: TaskItem) {
        // We need a due date and a valid ID to schedule a notification.
        guard let dueDate = task.dueDate, let taskId = task.id else { return }
        
        // --- Content: What the notification will say ---
        let content = UNMutableNotificationContent()
        content.title = "Task Due!"
        content.subtitle = task.title
        content.sound = UNNotificationSound.default
        
        // --- Trigger: When the notification will be delivered ---
        // We'll trigger it 5 seconds before the actual due date for testing.
        // For a real app, you might remove the `- 5`.
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dueDate.addingTimeInterval(-1800))
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // --- Request: The combination of content and trigger ---
        let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for task: \(task.title)")
            }
        }
    }
    
    // 3. Function to cancel a pending notification for a task.
    func cancelNotification(for task: TaskItem) {
        guard let taskId = task.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
        print("Cancelled notification for task: \(task.title)")
    }
}
