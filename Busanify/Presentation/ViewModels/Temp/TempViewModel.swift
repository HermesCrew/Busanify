//
//  TempViewModel.swift
//  Busanify
//
//  Created by 이인호 on 6/23/24.
//

import Foundation
import Combine

class TempViewModel {
    private let placeId: Int
    private var cancellables = Set<AnyCancellable>()
    private let useCase: PlaceDetailViewUseCase
    
    @Published var place: Place = Place(id: "", typeId: "", image: "", lat: 0, lng: 0, tel: "", avgRating: 0, title: "", address: "", openTime: nil, parking: nil, holiday: nil, fee: nil, reservationURL: nil, goodStay: nil, hanok: nil, menu: nil, shopguide: nil, restroom: nil, isBookmarked: false)
    
    init(placeId: Int, useCase: PlaceDetailViewUseCase) {
        self.placeId = placeId
        self.useCase = useCase
    }
    
    func fetchPlaces() {
        useCase.getPlace(by: placeId, lang: "eng")
            .receive(on: DispatchQueue.main)
            .assign(to: &$place)
    }
}
