//
//  PostDTO.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import Foundation

struct ReviewDTO: Codable {
    let placeId: String
    let rating: Int
    let content: String
    let photoUrls: [String]
}
