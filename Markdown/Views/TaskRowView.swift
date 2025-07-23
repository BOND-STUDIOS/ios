//
//  TaskRowView.swift
//  Markdown
//
//  Created by CJ Sanchez on 7/22/25.
//

import SwiftUI

struct TaskRowView: View{
    
    @Binding var task: TaskItem
    var taskManager: TaskManager // We'll need this to call the update function
    @ObservedObject var journeyManager: JourneyManager // ✅ Add this
    private var journeyTitle: String? {
            if let journeyID = task.journeyID {
                return journeyManager.journeys.first { $0.id == journeyID }?.title
            }
            return nil
        }
    @State private var isShowingEditView = false
    var body: some View {
        HStack(spacing: 15){
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .secondary)
                .font(.title2)
            
            VStack(alignment: .leading) {
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let journeyTitle = journeyTitle {
                    Text(journeyTitle)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            
            
                if let dueDate = task.dueDate {
                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }


        }
                .opacity(task.isCompleted ? 0.5 : 1.0)
            
        }
        .onTapGesture {
            task.isCompleted.toggle()
            taskManager.updateTask(task: task)
            if task.isCompleted {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
        }
        .contextMenu {
            Button {
                isShowingEditView = true
            } label: {
                Label("Edit Task", systemImage: "pencil")
            }
        }
        .sheet(isPresented: $isShowingEditView) {
            AddTaskView(
                journeyManager: journeyManager, onSave: { updatedTask in
                    taskManager.updateTask(task: updatedTask)
                    isShowingEditView = false // Dismiss the sheet
                },
                taskToEdit: task
            )
        }
    }
    
}
