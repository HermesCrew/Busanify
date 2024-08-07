//
//  Review.swift
//  Busanify
//
//  Created by 이인호 on 7/17/24.
//

import Foundation
import UIKit

struct Review: Identifiable, Hashable, Codable {
    let id: Int
    let rating: Double
    let content: String
    let photos: [String]
    let user: User
    let createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id, rating, content, photos, user, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        rating = try container.decode(Double.self, forKey: .rating)
        content = try container.decode(String.self, forKey: .content)
        photos = try container.decode([String].self, forKey: .photos)
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
