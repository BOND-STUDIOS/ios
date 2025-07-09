//
//  APIModels.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/8/25.
//

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
