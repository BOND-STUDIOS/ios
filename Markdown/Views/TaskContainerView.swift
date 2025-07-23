
import SwiftUI

struct TasksContainerView: View {
    @StateObject private var taskManager = TaskManager()
    @ObservedObject var journeyManager: JourneyManager // ✅ Add this

    @State private var isShowingAddTaskView = false

    var body: some View {
        NavigationStack {
            TabView {
                // We now pass the whole manager and a filter type to the list view
                TaskListView(taskManager: taskManager, journeyManager: journeyManager, filter: .deep)
                    .tabItem { Label("Deep Work", systemImage: "brain.head.profile") }

                TaskListView(taskManager: taskManager, journeyManager: journeyManager, filter: .shallow)
                    .tabItem { Label("Shallow Work", systemImage: "archivebox") }

                TaskListView(taskManager: taskManager, journeyManager: journeyManager, filter: .recharge)
                    .tabItem { Label("Recharge", systemImage: "battery.100.bolt") }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isShowingAddTaskView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddTaskView) {
                // ✅ Pass the journey manager in
                AddTaskView(journeyManager: journeyManager) { newTask in
                    taskManager.addTask(task: newTask)
                }
            }
            
            .sheet(isPresented: $isShowingAddTaskView) {
                AddTaskView(journeyManager: journeyManager) { newTask in
                    taskManager.addTask(task: newTask)
                }
            }
            .onAppear {
                taskManager.fetchTasks()
                journeyManager.fetchJourneys() // ✅ Fetch journeys when the view appears
            }
        }
    }
}
