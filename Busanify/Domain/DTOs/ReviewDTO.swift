//
//  PostDTO.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import Foundation

struct ReviewDTO: Codable {
    let rating: Double
    let content: String
    let photoUrls: [String]
}
