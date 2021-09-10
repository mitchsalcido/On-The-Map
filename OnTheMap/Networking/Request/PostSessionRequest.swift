//
//  PostSessionRequest.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import Foundation

// Request object for creating(posting) a new session (loggin in)
struct PostSessionRequest: Codable, LocalizedError {
    let udacity:SessionUserInfo
    enum CodingKeys: String, CodingKey {
        case udacity
    }
    var errorDescription: String? {
        return "Bad user input info"
    }
}

// Additional Response object for user info
struct SessionUserInfo: Codable {
    let username: String
    let password: String
    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
}
