//
//  BookmarkResponse.swift
//  Busanify
//
//  Created by seokyung on 7/12/24.
//

import Foundation

struct BookmarkResponse: Codable {
    let id: Int
    let deleted: Bool
    
    var isBookmarked: Bool {
        return !deleted
    }
}
