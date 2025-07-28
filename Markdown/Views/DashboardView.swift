import SwiftUI

struct DashboardView: View {
    // We now use the real TaskManager
    @StateObject private var taskManager = TaskManager()
    @StateObject private var journeyManager = JourneyManager() // ✅ Add this

    // This will hold the output of our engine
    @State private var recommendedTask: TaskItem?
    @State private var selectedTaskForAI: TaskItem?
    // When the user taps a button, this will trigger the recommendation
    @State private var selectedEnergy: EnergyLevel? {
        didSet {
            guard let energy = selectedEnergy else { return }
            self.recommendedTask = taskManager.recommendTask(for: energy)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Text("How's your energy right now?")
                        .font(.headline)
                    HStack {
                        Button("⚡️ High") { selectedEnergy = .deep }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        Button("🧠 Medium") { selectedEnergy = .shallow }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        Button("🧘 Low") { selectedEnergy = .recharge }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                    }
                }
                
                Divider()
                                
            // --- "Up Next" Card UI ---
            if let task = recommendedTask {
                VStack(alignment: .leading) {
                    Text("UP NEXT")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(task.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Label(task.energyLevel.rawValue, systemImage: "bolt.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red.opacity(0.8), in: Capsule())
                        .onTapGesture {
                            self.selectedTaskForAI = task
                        }
//                    Button("Start Focus Session") { /* Action later */ }
//                        .buttonStyle(.borderedProminent)
//                        .padding(.top)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                                        self.selectedTaskForAI = task
                                    }
            } else {
                ContentUnavailableView(
                    "Select Your Energy",
                    systemImage: "bolt.fill",
                    description: Text("Tap an energy level above to get your next task recommendation.")
                )
            }
            
            Spacer()

                // TODO: This button could link to the old TasksContainerView
                NavigationLink(destination: TasksContainerView(journeyManager: journeyManager)) {
                                    Text("View All Tasks")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
            }
            .padding()
            .navigationTitle("Dashboard")
            .onAppear {
                taskManager.fetchTasks() // Load all tasks when the view appears
                journeyManager.fetchJourneys()
            }
            .sheet(item: $selectedTaskForAI) { task in
                            TaskAssistantView(
                                taskManager: taskManager,
                                journeyManager: journeyManager,
                                task: task
                            )
                        }
        }
    }
}
