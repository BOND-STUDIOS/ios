//
//  JourneyItem.swift
//  Markdown
//
//  Created by CJ Sanchez on 7/22/25.
//

import Foundation
import FirebaseFirestore
struct Milestone: Codable, Identifiable, Hashable {
    // This can remain a UUID as it's just part of the journey's data array
    let id: UUID
    var title: String
    var isCompleted: Bool
}

struct Journey: Codable, Identifiable, Hashable {
    // ✅ Change this to match how Firestore handles IDs
    @DocumentID var id: String?
    
    var title: String
    var motivation: String
    var milestones: [Milestone]
    
    // Manual Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
