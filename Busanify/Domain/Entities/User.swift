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
    let name: String
    let profileImage: Data
    
    private enum CodingKeys: String, CodingKey {
        case id, email, name, profileImage
    }
    
    init(id: String, email: String?, name: String, profileImage: Data) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImage = profileImage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.name = try container.decode(String.self, forKey: .name)
        
        let profileImageURL = try container.decode(String.self, forKey: .profileImage)
        
        if let url = URL(string: profileImageURL), let data = try? Data(contentsOf: url) {
            self.profileImage = data
        } else {
            self.profileImage = Data()
        }
    }
}
