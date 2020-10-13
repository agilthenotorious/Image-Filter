//
//  Sections.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/6/20.
//

import Foundation

struct Sections {
    var provider: Provider
    var dataSource: [ImageProtocol]
}

protocol ImageProtocol {
    var imageUrl: String? { get }
    init(dict: [String: Any])
}

struct SplashImageInfo: ImageProtocol {
    var imageUrl: String?
    
    //enum CodingKeys: String, CodingKey {
    //    case imageUrl = "url"
    //}

    init(dict: [String: Any]) {
        self.imageUrl = dict["url"] as? String
    }
}

struct PexelsImageInfo: ImageProtocol {
    var imageUrl: String?
    
    //enum CodingKeys: String, CodingKey {
    //    case imageUrl = "medium"
    //}
    
    init(dict: [String: Any]) {
        if let srcDict = dict["src"] as? [String: Any] {
            self.imageUrl = srcDict["medium"] as? String
        }
    }
}

struct PixabayImageInfo: ImageProtocol {
    var imageUrl: String?
    
    //enum CodingKeys: String, CodingKey {
    //    case imageUrl = "webformatURL"
    //}
    //
    //enum HitKeys: String, CodingKey {
    //    case hits
    //}
    //
    //init(from decoder: Decoder) throws {
    //    let container = try decoder
    //    container.
    //}
    
    init(dict: [String: Any]) {
        self.imageUrl = dict["webformatURL"] as? String
    }
}
