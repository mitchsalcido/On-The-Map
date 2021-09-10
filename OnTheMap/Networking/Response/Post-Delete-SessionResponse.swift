//
//  Post-Delete-SessionResponse.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import Foundation

// Response object, result from posting new session (loggin in)
struct PostSessionResponse: Codable {
    let account: AccountInfo
    let session: SessionInfo
    enum CodingKeys: String, CodingKey {
        case account
        case session
    }
}

// Response object, result from deleting session (logging out)
struct DeleteSessionResponse: Codable {
    let session: SessionInfo
    enum CodingKeys: String, CodingKey {
        case session
    }
}

// Response object, user account info
struct AccountInfo: Codable {
    let registered: Bool
    let key: String
    enum CodingKeys: String, CodingKey {
        case registered
        case key
    }
    
}

// Response object, session info
struct SessionInfo: Codable {
    let sessionId: String
    let expiration: String
    enum CodingKeys: String, CodingKey {
        case sessionId = "id"
        case expiration
    }
}
