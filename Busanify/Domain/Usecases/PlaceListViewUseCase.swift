//
//  PlaceListViewUseCase.swift
//  Busanify
//
//  Created by 이인호 on 7/28/24.
//

import Foundation
import Combine

protocol PlaceListViewUseCase {
    func getPlaces(by typeId: PlaceType, lang: String, lat: Double, lng: Double, radius: Double) -> AnyPublisher<[Place], Never>
    func getPlaces(by title: String, lang: String) -> AnyPublisher<[Place], Never>
    func toggleBookmark(placeId: String, token: String) async throws
    func getBookmarkedPlaces(token: String, lang: String) -> AnyPublisher<[Bookmark], Error>
}
