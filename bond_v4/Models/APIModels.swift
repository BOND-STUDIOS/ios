//
//  APIModels.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/8/25.
//
import Foundation

struct SendPayload: Codable {
    var prompt: String
}

struct ResponsePayload: Codable{
    var text_response: String
    var audio_response_base64: String //base64
}

enum NetworkError: Error{
    case invalidURL
    case serverError(statusCode: Int)
    case decodingError
}
// In APIModels.swift


// ✅ NEW: A model for a single event from the stream
struct StreamedEvent: Decodable {
    let type: EventType
    let content: String?
    let audioBase64: String?
    
    // Maps the snake_case JSON keys to our camelCase properties
    enum CodingKeys: String, CodingKey {
        case type, content
        case audioBase64 = "audio_base64"
    }
}

// An enum for the different event types
enum EventType: String, Decodable {
    case start, text_chunk, audio_chunk, complete, error
}
