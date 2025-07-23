//
//  AddJourneyView.swift
//  Markdown
//
//  Created by CJ Sanchez on 7/22/25.
//

import SwiftUI

struct AddJourneyView: View {
    var onSave: (Journey) -> Void
    @Environment(\.dismiss) var dismiss
    var journeyToEdit: Journey?

    @State private var title = ""
    @State private var motivation = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Journey Details")) {
                    TextField("Title (e.g., Learn Guitar)", text: $title)
                    TextField("Motivation (e.g., To play at campfires)", text: $motivation)
                }
            }
            .navigationTitle(journeyToEdit == nil ? "Create Journey" : "Edit Journey") // ✅ Dynamic title
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // ✅ Update existing journey or create a new one
                        var journeyToSave = journeyToEdit ?? Journey(title: "", motivation: "", milestones: [])
                        journeyToSave.title = title
                        journeyToSave.motivation = motivation
                        
                        onSave(journeyToSave)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            // ✅ This pre-fills the form when editing
            .onAppear {
                if let journeyToEdit = journeyToEdit {
                    self.title = journeyToEdit.title
                    self.motivation = journeyToEdit.motivation
                }
            }
        }
    }
}
