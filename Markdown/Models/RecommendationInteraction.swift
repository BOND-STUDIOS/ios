import Foundation
import FirebaseFirestore

struct RecommendationInteraction: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let timestamp: Date

    // --- User Context Features ---
    let energyLevel: String // e.g., "deep", "shallow"
    let hourOfDay: Int // 0-23
    let dayOfWeek: Int // 1-7 (e.g., Sunday = 1)

    // --- Task Features ---
    let taskType: String // e.g., "deep", "shallow"
    let hasDueDate: Bool
    let daysUntilDue: Int?
    let journeyId: String?

    // --- The Outcome (The "Label") ---
    // 1 for success (task was completed), 0 for failure (ignored).
    let outcome: Int
}
