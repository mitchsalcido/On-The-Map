//
//  Student.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/7/21.
//

import Foundation

struct StudentInformation: Codable {
    let firstName: String
    let lastName: String
    let longitude: Double
    let latitude: Double
    let mapString: String
    let mediaURL: String
    let uniqueKey: String
    let objectId: String
    let createdAt: String
    let updatedAt: String
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case longitude
        case latitude
        case mapString
        case mediaURL
        case uniqueKey
        case objectId
        case createdAt
        case updatedAt
    }
}

struct StudentResultsResponse: Codable {
    let results: [StudentInformation]
    enum CodingKeys: String, CodingKey {
        case results
    }
}
