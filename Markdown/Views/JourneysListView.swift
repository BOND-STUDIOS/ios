
import SwiftUI

struct JourneysListView: View {
    @StateObject private var journeyManager = JourneyManager()
    @State private var isShowingAddJourneyView = false
    @State private var journeyToEdit: Journey?
        @State private var isShowingEditView = false

    var body: some View {
        NavigationStack {
            // We use the '$' to get bindings to the journeys array
            Group {
                if journeyManager.isLoading {
                    ProgressView() // Shows a spinning loading indicator
                } else if journeyManager.journeys.isEmpty {
                    ContentUnavailableView(
                        "No Journeys Yet",
                        systemImage: "map",
                        description: Text("Tap the '+' button to create your first long-term goal.")
                    )
                } else {
                    List {
                        // We now loop over the journey bindings
                        ForEach($journeyManager.journeys) { $journey in
                            NavigationLink(destination: JourneyDetailView(journeyManager: journeyManager, journey: $journey)) {
                                VStack(alignment: .leading) {
                                    Text(journey.title)
                                        .font(.headline)
                                    Text(journey.motivation)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            // ✅ Add the context menu
                            .contextMenu {
                                Button {
                                    self.journeyToEdit = journey
                                    self.isShowingEditView = true
                                } label: {
                                    Label("Edit Journey", systemImage: "pencil")
                                }
                            }
                        }
                        .onDelete(perform: deleteJourney) // ✅ Add this modifier
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
                AddJourneyView { newJourney in
                    journeyManager.addJourney(newJourney)
                }
            }
            .sheet(isPresented: $isShowingEditView) {
                AddJourneyView(
                    onSave: { updatedJourney in
                        journeyManager.updateJourney(updatedJourney)
                    },
                    journeyToEdit: journeyToEdit
                )
            }
            .onAppear {
                journeyManager.fetchJourneys()
            }
        }
    }
    private func deleteJourney(at offsets: IndexSet) {
        let journeysToDelete = offsets.map { journeyManager.journeys[$0] }
        for journey in journeysToDelete {
            journeyManager.deleteJourney(journey)
        }
    }
}
