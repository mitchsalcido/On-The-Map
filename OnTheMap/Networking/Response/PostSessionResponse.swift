//
//  PostSessionResponse.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import Foundation

struct PostSessionResponse: Codable {
    let account: AccountInfo
    let session: SessionInfo
    enum CodingKeys: String, CodingKey {
        case account
        case session
    }
}

struct DeleteSessionResponse: Codable {
    let session: SessionInfo
    enum CodingKeys: String, CodingKey {
        case session
    }
}

struct PostSessionErrorResponse: Codable, LocalizedError {
    let status: Int
    let error: String
    enum CodingKeys: String, CodingKey {
        case status
        case error
    }
    var errorDescription: String? {
        return error
    }
}

struct AccountInfo: Codable {
    let registered: Bool
    let key: String
    enum CodingKeys: String, CodingKey {
        case registered
        case key
    }
}
struct SessionInfo: Codable {
    let sessionId: String
    let expiration: String
    enum CodingKeys: String, CodingKey {
        case sessionId = "id"
        case expiration
    }
}
