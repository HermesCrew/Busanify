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
    let commentsCount: Int
    let createdAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id, content, photoUrls, user, commentsCount, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        photoUrls = try container.decode([String].self, forKey: .photoUrls)
        user = try container.decode(User.self, forKey: .user)
        commentsCount = try container.decode(Int.self, forKey: .commentsCount)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: createdAtString) {
            let relativeTime = Self.relativeTimeString(from: date)
            createdAt = relativeTime
        } else {
            createdAt = createdAtString
        }
    }
    
    static func relativeTimeString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // 현재 시간과 입력 시간 사이의 경과 시간 계산
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)

        // 1년 이상
        if let years = components.year, years > 0 {
            return "\(years) years ago"
        }
        
        // 1달 이상
        if let months = components.month, months > 0 {
            return "\(months) months ago"
        }
        
        // 1일 이상
        if let days = components.day, days > 0 {
            return "\(days) days ago"
        }
        
        // 1시간 이상
        if let hours = components.hour, hours > 0 {
            return "\(hours) hours ago"
        }
        
        // 1분 이상
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minutes ago"
        }
        
        // 1분 이내
        if let seconds = components.second, seconds > 0 {
            return "\(seconds) seconds ago"
        }
        
        return "now"
    }
}
