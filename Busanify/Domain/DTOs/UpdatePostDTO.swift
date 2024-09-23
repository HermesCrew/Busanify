//
//  UpdatePostDTO.swift
//  Busanify
//
//  Created by 이인호 on 9/23/24.
//

import Foundation

struct UpdatePostDTO: Codable {
    let id: Int
    let content: String
    let photoUrls: [String]
}
