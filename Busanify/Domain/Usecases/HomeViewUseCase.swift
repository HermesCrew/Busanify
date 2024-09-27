//
//  HomeViewUseCase.swift
//  Busanify
//
//  Created by 이인호 on 6/23/24.
//

import Foundation
import Combine

protocol HomeViewUseCase {
    func getPlaces(by typeId: PlaceType, lang: String, lat: Double, lng: Double, radius: Double) -> AnyPublisher<[Place], Never>
    func getPlaces(by title: String, lang: String) -> AnyPublisher<[Place], Never>
}
