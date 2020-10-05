//
//  ApiResponse.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/2/20.
//

import Foundation

struct ApiResponse: Decodable {
    var images: [ImageInfo]?
}

struct ImageInfo: Decodable {
    var identifier: Int?
    var url: String?
    var largeUrl: String?
    var sourceId: Int?
    var copyright: String?
    var site: String?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case url
        case largeUrl = "large_url"
        case sourceId = "source_id"
        case copyright
        case site
    }
}
