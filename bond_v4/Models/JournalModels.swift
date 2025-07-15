////
////  JournalModels.swift
////  bond_v4
////
////  Created by CJ Sanchez on 7/9/25.
////
//
//struct JournalEntry: Identifiable {
//    
//}


import Foundation

struct JournalEntry: Codable, Identifiable, Hashable {
    let journal_id: String
    let timestamp: String
    let content: String
    let user_id: String

    // Use journal_id for the Identifiable conformance
    var id: String {
        return journal_id
    }
    
    // Formatted date for display
    var formattedDate: String {
            let formatter = DateFormatter()

            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            if let date = formatter.date(from: timestamp) {
                return date.formatted(date: .long, time: .shortened)
            }
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: timestamp) {
                return date.formatted(date: .long, time: .shortened)
            }

                return "Invalid Date"
            }
}
