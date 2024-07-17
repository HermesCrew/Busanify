//
//  Place.swift
//  Busanify
//
//  Created by 이인호 on 6/23/24.
//

import Foundation

struct Place: Identifiable, Hashable, Codable {
    let id: String
    let typeId: String
    let image: String
    let lat: Double
    let lng: Double
    let tel: String
    let avgRating: Int
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
    var isBookmarked: Bool
}
