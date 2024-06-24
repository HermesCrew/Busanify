//
//  PlaceDetailViewUseCase.swift
//  Busanify
//
//  Created by 이인호 on 6/23/24.
//

import Foundation
import Combine

protocol PlaceDetailViewUseCase {
    func getPlace(by id: Int, lang: String) -> AnyPublisher<Place, Never>
}
