//
//  User.swift
//  Busanify
//
//  Created by 이인호 on 7/23/24.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    let email: String?
    let nickname: String
    let profileImage: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, email, nickname, profileImage
    }
    
    init(id: String, email: String?, nickname: String, profileImage: String?) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.profileImage = profileImage
    }
}
