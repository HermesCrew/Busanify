//
//  PlaceType.swift
//  Busanify
//
//  Created by 이인호 on 6/23/24.
//

import UIKit

enum PlaceType: Int, Codable, CaseIterable {
    case touristAttraction = 76
    case shopping = 79
    case accommodation = 80
    case restaurant = 82
    
    var placeInfo: (String, String, UIColor) {
        // MARK: TODO - tuple 0번째 locale로 수정
        get {
            switch self {
            case .touristAttraction:
                return ("관광지", "flag.fill", UIColor.systemRed)
            case .restaurant:
                return ("음식점", "fork.knife", UIColor.systemOrange)
            case .accommodation:
                return ("숙박", "bed.double.fill", UIColor.systemYellow)
            case .shopping:
                return ("쇼핑", "handbag.fill", UIColor.systemPurple)
            }
        }
    }

}
