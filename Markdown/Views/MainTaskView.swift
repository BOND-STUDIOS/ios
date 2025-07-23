import SwiftUI

struct MainTaskView: View {
    // This @State variable will keep track of which destination is currently selected.
    @State private var selection: NavDestination? = .tasks
        @State private var isShowingCompass = false
        
        // ✅ Create an array of the navigation destinations
        private let destinations: [NavDestination] = [.tasks, .journeys]

        var body: some View {
            NavigationSplitView {
                List(selection: $selection) {
                    // ✅ Loop through the destinations to create the links
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
                    
                    // --- This Section is now outside the ForEach loop ---
                    Section("Review") {
                        Button(action: {
                            isShowingCompass = true
                        }) {
                            Label("Weekly Compass", systemImage: "safari.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .navigationTitle("Menu")
                
            } detail: {
                switch selection {
                case .tasks:
                    DashboardView()
                case .journeys:
                    JourneysListView()
                case .none:
                    Text("Select a category")
                }
            }
            .sheet(isPresented: $isShowingCompass) {
                WeeklyCompassView()
            }
            
            
            ////////////////
            .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
