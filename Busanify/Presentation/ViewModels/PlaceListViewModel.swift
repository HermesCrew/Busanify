//
//  PlaceListViewModel.swift
//  Busanify
//
//  Created by seokyung on 7/1/24.
//

import Foundation
import Combine

final class PlaceListViewModel {
    private var cancellables = Set<AnyCancellable>()
    private let useCase: HomeViewUseCase
    
    @Published var places: [Place] = []
    
    init(useCase: HomeViewUseCase) {
        self.useCase = useCase
    }
    
    func fetchPlaces(typeId: PlaceType, lang: String, lat: Double, lng: Double, radius: Double) {
        useCase.getPlaces(by: typeId, lang: lang, lat: lat, lng: lng, radius: radius)
            .map { Array(Set($0)) }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Successfully received data")
                case .failure(let error):
                    print("Error receiving data: \(error)")
                }
            } receiveValue: { [weak self] places in
                print("Received places: \(places.count) items") // 데이터 출력
                self?.places = places
            }
            .store(in: &cancellables)
    }
    
    func fetchPlaces(by title: String, lang: String) {
        useCase.getPlaces(by: title, lang: lang)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Successfully received data")
                case .failure(let error):
                    print("Error receiving data: \(error)")
                }
            } receiveValue: { [weak self] places in
                print("Received places: \(places)") // 데이터 출력
                self?.places = places
            }
            .store(in: &cancellables)
    }
}
