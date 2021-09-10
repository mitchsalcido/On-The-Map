//
//  DataResponse.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/9/21.
//

import Foundation

// Response object, results of Data object returned
struct DataResponse: Codable {
    let data: Data
    enum CodingKeys: String, CodingKey {
        case data
    }
}
