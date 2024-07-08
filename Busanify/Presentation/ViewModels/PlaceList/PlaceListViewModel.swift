//
//  PlaceListViewModel.swift
//  Busanify
//
//  Created by seokyung on 7/1/24.
//

import Foundation
import Combine

struct PlaceCellViewModel {
    let title: String
    let address: String
    let openTime: String
    let imageURL: URL?
    var isBookmarked: Bool

    init(place: Place, isBookmarked: Bool = false) {
        self.title = place.title
        self.address = place.address
        self.openTime = place.openTime ?? "영업시간 정보 없음"
        self.imageURL = URL(string: place.image)
        self.isBookmarked = isBookmarked
    }
}

final class PlaceListViewModel {
    @Published var placeCellViewModels: [PlaceCellViewModel] = []
    private var cancellables = Set<AnyCancellable>()
    private let useCase: HomeViewUseCase
    
    @Published var places: [Place] = []
    
    init(useCase: HomeViewUseCase) {
        self.useCase = useCase
    }
    
    func fetchPlaces(typeId: PlaceType, lang: String, lat: Double, lng: Double, radius: Double) {
        useCase.getPlaces(by: typeId, lang: lang, lat: lat, lng: lng, radius: radius)
            .map { Array(Set($0)) }
            .map { places in places.map { PlaceCellViewModel(place: $0) } }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Successfully received data")
                case .failure(let error):
                    print("Error receiving data: \(error)")
                }
            } receiveValue: { [weak self] cellViewModels in
                            print("Received places: \(cellViewModels.count) items")
                            self?.placeCellViewModels = cellViewModels
                        }
            .store(in: &cancellables)
    }
    
    func fetchPlaces(by title: String, lang: String) {
        useCase.getPlaces(by: title, lang: lang)
            .map { places in places.map { PlaceCellViewModel(place: $0) } }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Successfully received data")
                case .failure(let error):
                    print("Error receiving data: \(error)")
                }
            } receiveValue: { [weak self] cellViewModels in
                            print("Received places: \(cellViewModels.count)")
                            self?.placeCellViewModels = cellViewModels
                        }
            .store(in: &cancellables)
    }
}
