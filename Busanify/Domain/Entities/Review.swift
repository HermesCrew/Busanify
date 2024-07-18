//
//  Review.swift
//  Busanify
//
//  Created by 이인호 on 7/17/24.
//

import Foundation

struct Review: Identifiable, Hashable, Codable {
    let id: Int
    let rating: Double
    let content: String
    let photos: [String]
    let username: String
    let createdAt: String
}
