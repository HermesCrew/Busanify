//
//  DetailViewModel.swift
//  Busanify
//
//  Created by 이인호 on 7/11/24.
//

import Foundation
import Combine

final class PlaceDetailViewModel {
    private let placeId: String
    private var cancellables = Set<AnyCancellable>()
    private let useCase: PlaceDetailViewUseCase
    
    @Published var place: Place = Place(id: "", typeId: "", image: "", lat: 0, lng: 0, tel: "", title: "", address: "", openTime: nil, parking: nil, holiday: nil, fee: nil, reservationURL: nil, goodStay: nil, hanok: nil, menu: nil, shopguide: nil, restroom: nil, isBookmarked: false, avgRating: 0.0, reviews: nil, reviewCount: nil)
    
    init(placeId: String, useCase: PlaceDetailViewUseCase) {
        self.placeId = placeId
        self.useCase = useCase
    }
    
    func fetchPlace(token: String?) {
        useCase.getPlace(by: placeId, lang: "eng", token: token)
            .receive(on: DispatchQueue.main)
            .assign(to: &$place)
    }
    
    func toggleBookmarkPlace(token: String?) {
        guard let token = token else { return }
        
        useCase.toggleBookmark(placeId: placeId, token: token)
    }
}
