//
//  Bookmark.swift
//  Busanify
//
//  Created by seokyung on 7/12/24.
//

import Foundation

struct Bookmark: Codable {
    let id: String
    let typeId: String
    let image: String
    let avgRating: Double
    let reviewCount: Int
    let title: String
}
