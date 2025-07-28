import SwiftUI

struct UpNextCardView: View {
    // It now receives a binding to the task and the TaskManager
    @Binding var task: TaskItem
    var taskManager: TaskManager
    
    // The action to open the AI Assistant sheet is passed in from the parent
    var onCardTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // --- Checkmark Button ---
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .secondary)
                .font(.largeTitle)
                .onTapGesture {
                    task.isCompleted.toggle()
                    taskManager.updateTask(task: task)
                    if task.isCompleted {
                        // Haptic feedback for completion
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                }

            // --- Main Content ---
            VStack(alignment: .leading) {
                Text("UP NEXT")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(task.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .strikethrough(task.isCompleted)
            }
            .opacity(task.isCompleted ? 0.5 : 1.0)
            
            Spacer() // Pushes content to the left
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        // The tap gesture for the whole card now opens the AI sheet
        .contentShape(Rectangle()) // Makes the whole area tappable
        .onTapGesture {
            onCardTap()
        }
    }
}
