//
//  WeeklyReview.swift
//  Markdown
//
//  Created by CJ Sanchez on 7/23/25.
//
import Foundation
import FirebaseFirestore

struct WeeklyReview: Codable, Identifiable {
    @DocumentID var id: String?
    var reviewDate: Date
    var wins: String
    var challenges: String
    var priorities: String
    var tasksCompleted: Int
}
