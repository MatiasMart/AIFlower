//
//  WikiData.swift
//  AIFlower
//
//  Created by Matias Martinelli on 29/08/2023.
//

import Foundation

struct WikiData: Codable {
    var query: Query
}
struct Query: Codable {
    var pageids: [String]
    var pages: [String : Pages]
}
struct PageIds: Codable, Hashable {
    var id: [String]
}
struct Pages: Codable {
    var extract: String
    var thumbnail: Thumbnail
}

struct Thumbnail: Codable {
    var source: String
}


