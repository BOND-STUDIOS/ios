
import SwiftUI

struct TaskListView: View {
    // It now observes the whole manager
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var journeyManager: JourneyManager // ✅ Add this

    // It receives a filter to know which tasks to show
    var filter: EnergyLevel

    // This computed property will always give us the correct, filtered list
    private var filteredTasks: [TaskItem] {
        taskManager.tasks.filter { $0.energyLevel == filter }
    }
    
    var body: some View {
        Group {
            if taskManager.isLoading {
                ProgressView() // Shows a spinning loading indicator
            } else if taskManager.tasks.isEmpty {
                ContentUnavailableView(
                    "No tasks Yet",
                    systemImage: "pencil",
                    description: Text("Tap the '+' button to create your first Task.")
                )
            } else {List {
                // We loop through the filtered list
                ForEach(filteredTasks) { task in
                    // We must find the index of this task in the ORIGINAL array
                    // to create a direct binding. This is the key to the fix.
                    if let index = taskManager.tasks.firstIndex(where: { $0.id == task.id }) {
                        TaskRowView(task: $taskManager.tasks[index], taskManager: taskManager, journeyManager: journeyManager)
                    }
                }
                .onDelete(perform: deleteTask)
            }
            .listStyle(.plain)}}
        
    }

    private func deleteTask(at offsets: IndexSet) {
        let tasksToDelete = offsets.map { filteredTasks[$0] }
        for task in tasksToDelete {
            taskManager.deleteTask(task: task)
        }
    }
}
