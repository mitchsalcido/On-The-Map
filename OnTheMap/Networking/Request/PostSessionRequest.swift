//
//  PostSessionRequest.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import Foundation
struct PostSessionRequest: Codable {
    let udacity:SessionUserInfo
    enum CodingKeys: String, CodingKey {
        case udacity
    }
}

struct SessionUserInfo: Codable {
    let username: String
    let password: String
    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
}

extension PostSessionRequest: LocalizedError {
    var errorDescription: String? {
        return "Bad user input info"
    }
}
