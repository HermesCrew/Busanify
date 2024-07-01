//
//  Place.swift
//  Busanify
//
//  Created by 이인호 on 6/23/24.
//

import Foundation

struct Place: Identifiable, Hashable, Codable {
    let id: Int
    let typeId: String
    let image: String
    let lat: Double
    let lng: Double
    let tel: String
    let title: String
    let address: String
    let openTime: String?
    let parking: String?
    let holiday: String?
    let fee: String?
    let reservationURL: String?
    let goodStay: Int?
    let hanok: Int?
    let menu: String?
    let shopguide: String?
    let restroom: Int?
}

extension Place {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title) // 또는 고유성을 보장하는 다른 속성
    }

    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.title == rhs.title // 또는 동등성을 정확히 판단할 수 있는 다른 속성들
    }
}
