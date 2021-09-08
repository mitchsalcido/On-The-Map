//
//  StudentLocation-UpdateResponse.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/7/21.
//

import Foundation

struct StudentLocationResponse: Codable {
    let createdAt: String
    let objectId: String
    enum CodingKeys: String, CodingKey {
        case createdAt
        case objectId
    }
}

struct UpdateStudentLocationResponse: Codable {
    let updatedAt: String
    enum CodingKeys: String, CodingKey {
        case updatedAt
    }
}
