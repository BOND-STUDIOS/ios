
import SwiftUI

struct AddTaskView: View {
    // This property holds the function that passes the new task back
    @ObservedObject var journeyManager: JourneyManager // ✅
    var onSave: (TaskItem) -> Void
    @State private var selectedJourneyId: String? = nil // ✅ State to hold the selection

    @State private var hasDueDate = false
        @State private var dueDate = Date()
    // This property gives us a way to close the sheet
    @Environment(\.dismiss) var dismiss
    var taskToEdit: TaskItem?

    // Your @State variables
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedEnergyLevel: EnergyLevel = .shallow

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("e.g., Write the project proposal", text: $title)
                    TextEditor(text: $description)
                                            .frame(height: 100) // Give it a nice default size
                    Picker("Energy Level", selection: $selectedEnergyLevel) {
                        ForEach(EnergyLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section(header: Text("Assign to Journey")) {
                                    Picker("Journey", selection: $selectedJourneyId) {
                                        Text("None").tag(String?.none) // Option for no journey
                                        ForEach(journeyManager.journeys) { journey in
                                            Text(journey.title).tag(journey.id)
                                        }
                                    }
                                }
                Section(header: Text("Due Date")) {
                                    Toggle("Set Due Date", isOn: $hasDueDate.animation())
                                    if hasDueDate {
                                        DatePicker("Date & Time", selection: $dueDate)
                                    }
                                }
            }
            .navigationTitle(taskToEdit == nil ? "Add New Task" : "Edit Task") // Dynamic title
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Modify the existing task or create a new one
                        var taskToSave = taskToEdit ?? TaskItem(title: "", isCompleted: false, energyLevel: .shallow)
                        
                        taskToSave.title = title
                        taskToSave.description = description
                        taskToSave.energyLevel = selectedEnergyLevel
                        taskToSave.journeyID = selectedJourneyId // ✅ Add this line

                        taskToSave.dueDate = hasDueDate ? dueDate : nil
                        onSave(taskToSave)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let taskToEdit = taskToEdit {
                    self.title = taskToEdit.title
                    self.description = taskToEdit.description ?? ""
                    self.selectedEnergyLevel = taskToEdit.energyLevel
                    self.selectedJourneyId = taskToEdit.journeyID
                    if let aDueDate = taskToEdit.dueDate {
                                            self.hasDueDate = true
                                            self.dueDate = aDueDate
                                        }
                }
            }
        }
    }
}
