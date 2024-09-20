//
//  PostDTO.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import Foundation

struct PostDTO: Codable {
    let content: String
    let photoUrls: [String]
}
