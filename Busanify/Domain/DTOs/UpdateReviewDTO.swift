//
//  UpdateReviewDTO.swift
//  Busanify
//
//  Created by MadCow on 2024/9/26.
//

import Foundation

struct UpdateReviewDTO: Codable {
    let id: String
    let rating: Double
    let content: String
    let photoUrls: [String]
}