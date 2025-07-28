import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var journeyManager: JourneyManager

    @State private var recommendedTask: TaskItem?
    @State private var selectedTaskForAI: TaskItem?
    @State private var taskRecommendedForLogging: TaskItem? // We need this again
    @State private var selectedEnergy: EnergyLevel?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                EnergyCheckinView(selectedEnergy: $selectedEnergy)
                
                Divider()
                
                if let task = recommendedTask,
                   let taskIndex = taskManager.tasks.firstIndex(where: { $0.id == task.id }) {
                    // We found the recommended task in our main array.
                    // Now we can create a direct binding to it.
                    UpNextCardView(
                        task: $taskManager.tasks[taskIndex], // Pass the binding
                        taskManager: taskManager,            // Pass the manager
                        onCardTap: {                         // Pass the tap action
                            self.selectedTaskForAI = task
                        }
                    )
                } else {
                    ContentUnavailableView(
                        "Select Your Energy",
                        systemImage: "bolt.fill",
                        description: Text("Tap an energy level above to get your next task recommendation.")
                    )
                }
                
                
                Spacer()
                
                NavigationLink(destination: TasksContainerView(taskManager: taskManager, journeyManager: journeyManager)) {
                    Text("View All Tasks") // ... styling
                }
            }
            .padding()
            .navigationTitle("Dashboard")
//            .onAppear {
//                taskManager.fetchTasks()
//                journeyManager.fetchJourneys()
//            }
            .sheet(item: $selectedTaskForAI) { task in
                TaskAssistantView(taskManager: taskManager, journeyManager: journeyManager, task: task)
            }
            .onChange(of: selectedEnergy) { _, _ in
                updateRecommendation()
            }
            // ✅ This new modifier listens for the specific "task updated" event.
            .onReceive(taskManager.taskUpdatedPublisher) { updatedTask in
                handleTaskUpdate(updatedTask)
            }
        }
    }
    
    // --- Helper Functions ---
    
    private func updateRecommendation() {
        guard let energy = selectedEnergy else {
            recommendedTask = nil
            return
        }
        self.recommendedTask = taskManager.recommendTask(for: energy, journeys: journeyManager.journeys)
        self.taskRecommendedForLogging = self.recommendedTask
    }
    
    // This function runs ONLY when a task is updated.
    private func handleTaskUpdate(_ updatedTask: TaskItem) {
        // First, check if there was a recommended task we were tracking.
        guard let recommended = taskRecommendedForLogging else { return }

        // Case 1: The updated task IS the one we recommended, and it's now complete.
        if updatedTask.id == recommended.id && updatedTask.isCompleted {
            log(interactionOutcome: 1, for: recommended)
        }
        // Case 2: The updated task is NOT the one we recommended, but it is now complete.
        else if updatedTask.id != recommended.id && updatedTask.isCompleted {
            log(interactionOutcome: 0, for: recommended)
        }
    }
    
    private func log(interactionOutcome: Int, for task: TaskItem) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .weekday], from: Date())
        
        let interaction = RecommendationInteraction(
            userId: Auth.auth().currentUser?.uid ?? "unknown",
            timestamp: Date(),
            energyLevel: selectedEnergy?.rawValue ?? "unknown",
            hourOfDay: components.hour ?? 0,
            dayOfWeek: components.weekday ?? 0,
            taskType: task.energyLevel.rawValue,
            hasDueDate: task.dueDate != nil,
            daysUntilDue: task.dueDate != nil ? Calendar.current.dateComponents([.day], from: Date(), to: task.dueDate!).day : nil,
            journeyId: task.journeyID,
            outcome: interactionOutcome
        )
        
        taskManager.logInteraction(interaction)
        
        // Reset the logging state.
        self.taskRecommendedForLogging = nil
    }
}
