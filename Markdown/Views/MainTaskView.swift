import SwiftUI

struct MainTaskView: View {
    // ✅ Create the managers here. This view now "owns" the data.
    @StateObject private var taskManager = TaskManager()
    @StateObject private var journeyManager = JourneyManager()
    
    @State private var selection: NavDestination? = .tasks
    @State private var isShowingCompass = false
    
    private let destinations: [NavDestination] = [.tasks, .journeys]

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(destinations, id: \.self) { destination in
                    NavigationLink(value: destination) {
                        switch destination {
                        case .tasks:
                            Label("Tasks", systemImage: "checkmark.circle.fill")
                        case .journeys:
                            Label("Journeys", systemImage: "map.fill")
                        }
                    }
                }
                
                Section("Review") {
                    Button(action: { isShowingCompass = true }) {
                        Label("Weekly Compass", systemImage: "safari.fill")
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Menu")
            
        } detail: {
            switch selection {
            case .tasks:
                // ✅ Pass the managers down to the DashboardView
                DashboardView(taskManager: taskManager, journeyManager: journeyManager)
            case .journeys:
                // ✅ Pass the journeyManager down to the JourneysListView
                JourneysListView(journeyManager:journeyManager)
            case .none:
                Text("Select a category")
            }
        }
        .sheet(isPresented: $isShowingCompass) {
            WeeklyCompassView()
        }
        .onAppear {
            // ✅ Fetch all data once when the main app view appears
            taskManager.fetchTasks()
            journeyManager.fetchJourneys()
            NotificationManager.shared.requestAuthorization()
        }
    }
}
