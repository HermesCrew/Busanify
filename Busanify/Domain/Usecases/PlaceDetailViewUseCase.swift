//
//  PlaceDetailViewUseCase.swift
//  Busanify
//
//  Created by 이인호 on 6/23/24.
//

import Foundation
import Combine

protocol PlaceDetailViewUseCase {
    func getPlace(by id: String, lang: String, token: String?) -> AnyPublisher<Place, Never>
    func toggleBookmark(placeId: String, token: String)
    func deleteReview(by id: Int, token: String) async throws
}
