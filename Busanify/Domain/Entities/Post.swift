//
//  Post.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import Foundation

struct Post: Identifiable, Hashable, Codable {
    let id: Int
    let content: String
    let photoUrls: [String]
    let user: User
    let createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id, content, photoUrls, user, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        photoUrls = try container.decode([String].self, forKey: .photoUrls)
        user = try container.decode(User.self, forKey: .user)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: createdAtString) {
            let convertFormatter = DateFormatter()
            convertFormatter.dateFormat = "yyyy.MM.dd HH:mm"
            createdAt = convertFormatter.string(from: date)
        } else {
            createdAt = createdAtString
        }
    }
}
