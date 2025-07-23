import SwiftUI

struct JourneyDetailView: View {
    // It now receives the JourneyManager to handle saving.
    @ObservedObject var journeyManager: JourneyManager
    
    @Binding var journey: Journey
    @State private var newMilestoneTitle = ""
    
    // This will keep track of whether our TextField is focused.
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 4) {
                Text(journey.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(journey.motivation)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            HStack {
                TextField("New Milestone", text: $newMilestoneTitle)
                    // Bind the TextField's focus to our state variable
                    .focused($isTextFieldFocused)
                
                Button("Add") {
                    guard !newMilestoneTitle.isEmpty else { return }
                    let newMilestone = Milestone(id: UUID(), title: newMilestoneTitle, isCompleted: false)
                    journey.milestones.append(newMilestone)
                    
                    // 1. Immediately save the change.
                    journeyManager.updateJourney(journey)
                    
                    // 2. Clear the text field.
                    newMilestoneTitle = ""
                    
                    // 3. Dismiss the keyboard.
                    isTextFieldFocused = false
                }
                .disabled(newMilestoneTitle.isEmpty)
            }
            .padding()

            List($journey.milestones) { $milestone in
                HStack {
                    Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(milestone.isCompleted ? .green : .secondary)
                    Text(milestone.title)
                        .strikethrough(milestone.isCompleted)
                }
                .onTapGesture {
                    milestone.isCompleted.toggle()
                    // Immediately save the change when a milestone is toggled.
                    journeyManager.updateJourney(journey)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
