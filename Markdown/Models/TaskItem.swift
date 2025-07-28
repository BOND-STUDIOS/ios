import Foundation
import FirebaseFirestore// Import this new library

struct TaskItem: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    
    var title: String
    var description: String? // Changed to optional to match AddTaskView
    var isCompleted: Bool
    var dueDate: Date?
    var energyLevel: EnergyLevel
    var journeyID: String?
    var completedAt: Date?

    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// EnergyLevel enum remains the same
enum EnergyLevel: String, Codable, Hashable, CaseIterable {
    case deep = "Deep Work"
    case shallow = "Shallow Work"
    case recharge = "Recharge"
}
