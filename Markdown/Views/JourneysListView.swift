import SwiftUI

struct JourneysListView: View {
    // ✅ Change this to @ObservedObject to RECEIVE the manager
    @ObservedObject var journeyManager: JourneyManager
    
    @State private var isShowingAddJourneyView = false
    @State private var journeyToEdit: Journey?
    @State private var isShowingEditView = false

    var body: some View {
        NavigationStack {
            Group {
                if journeyManager.isLoading {
                    ProgressView()
                } else if journeyManager.journeys.isEmpty {
                    ContentUnavailableView(
                        "No Journeys Yet",
                        systemImage: "map",
                        description: Text("Tap the '+' button to create your first long-term goal.")
                    )
                } else {
                    List {
                        ForEach($journeyManager.journeys) { $journey in
                            NavigationLink(destination: JourneyDetailView(journeyManager: journeyManager, journey: $journey)) {
                                VStack(alignment: .leading) {
                                    Text(journey.title)
                                        .font(.headline)
                                    Text(journey.motivation)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .contextMenu {
                                    Button {
                                        self.journeyToEdit = journey
                                        self.isShowingEditView = true
                                    } label: {
                                        Label("Edit Journey", systemImage: "pencil")
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteJourney)
                    }
                }
            }
            .navigationTitle("My Journeys")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isShowingAddJourneyView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddJourneyView) {
                // For adding, you need to pass the shared manager instance
                AddJourneyView(journeyManager: journeyManager) { newJourney in
                    journeyManager.addJourney(newJourney)
                }
            }
            .sheet(isPresented: $isShowingEditView) {
                // For editing, you also need to pass the shared manager instance
                AddJourneyView(
                    journeyManager: journeyManager, // Pass the manager here as well
                    onSave: { updatedJourney in
                        journeyManager.updateJourney(updatedJourney)
                    },
                    journeyToEdit: journeyToEdit
                )
            }
            // ❌ Remove the .onAppear modifier from this file.
            // The parent MainTaskView now handles fetching.
        }
    }

    private func deleteJourney(at offsets: IndexSet) {
        let journeysToDelete = offsets.map { journeyManager.journeys[$0] }
        for journey in journeysToDelete {
            journeyManager.deleteJourney(journey)
        }
    }
}
