//
//  Comment.swift
//  Busanify
//
//  Created by 이인호 on 9/23/24.
//

import Foundation

struct Comment: Identifiable, Hashable, Codable {
    let id: Int
    let content: String
    let user: User
    let createdAt: String
}
