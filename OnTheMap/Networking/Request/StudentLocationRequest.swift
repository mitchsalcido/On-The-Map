//
//  StudentLocationRequest.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/7/21.
//

import Foundation

struct StudentLocationRequest: Codable {
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    enum CodingKeys: String, CodingKey {
        case uniqueKey
        case firstName
        case lastName
        case mapString
        case mediaURL
        case latitude
        case longitude
    }
}
