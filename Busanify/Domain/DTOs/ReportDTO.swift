//
//  ReportType.swift
//  Busanify
//
//  Created by 이인호 on 9/15/24.
//

import Foundation

struct ReportDTO: Codable {
    let reportedContentId: Int
    let reportedUserId: String
    let content: String
    let reportType: ReportType
}

enum ReportType: Int, Codable {
    case review
    case post
    case comment
}
