import SwiftUI

struct WeeklyCompassView: View {
    @Environment(\.dismiss) var dismiss
    
    // Create an instance of the manager to call its functions.
    @StateObject private var taskManager = TaskManager()
    
    // State to hold the data we fetch.
    @State private var completedTasksCount: Int = 0
    
    // State for the text editors.
    @State private var winsText: String = ""
    @State private var challengesText: String = ""
    @State private var prioritiesText: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                Text("Weekly Compass")
                    .font(.largeTitle).bold()
                    .padding(.top)
                
                TabView {
                    // --- PAGE 1: LOOK BACK ---
                    Form {
                        Section(header: Text("Last 7 Days")) {
                            // This now shows the real data!
                            Text("You completed \(completedTasksCount) tasks.")
                        }
                        
                        // ✅ ADDED THIS SECTION
                        Section(header: Text("What were your big wins?")) {
                            TextEditor(text: $winsText)
                                .frame(height: 100)
                        }
                        
                        // ✅ ADDED THIS SECTION
                        Section(header: Text("What challenges came up?")) {
                            TextEditor(text: $challengesText)
                                .frame(height: 100)
                        }
                    }
                    
                    // ✅ ADDED THIS ENTIRE SECOND PAGE
                    // --- PAGE 2: LOOK FORWARD ---
                    Form {
                        Section(header: Text("What are your top 1-3 priorities for next week?")) {
                            TextEditor(text: $prioritiesText)
                                .frame(height: 150)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save & Close") {
                        // 1. Create the review object from the current state.
                        let newReview = WeeklyReview(
                            reviewDate: Date(),
                            wins: winsText,
                            challenges: challengesText,
                            priorities: prioritiesText,
                            tasksCompleted: completedTasksCount
                        )
                        
                        // 2. Call the save function.
                        taskManager.saveReview(newReview)
                        
                        // 3. Dismiss the view.
                        dismiss()
                    }
                }
            }
            // When the view appears, call the fetch function.
            .onAppear {
                taskManager.fetchCompletedTasks(forLast: 7) { fetchedTasks in
                    self.completedTasksCount = fetchedTasks.count
                }
            }
        }
    }
}
