//
//  PlaceListViewModel.swift
//  Busanify
//
//  Created by seokyung on 7/1/24.
//

import Foundation
import Combine

struct PlaceCellViewModel {
    let id: String
    let title: String
    let address: String
    let openTime: String?
    let imageURL: URL?
    var isBookmarked: Bool
    let avgRating: Int

    init(place: Place) {
        self.id = place.id
        self.title = place.title
        self.address = place.address
        self.openTime = place.openTime.flatMap { $0.isEmpty ? nil : $0 }
        self.imageURL = URL(string: place.image)
        self.isBookmarked = place.isBookmarked
        self.avgRating = place.avgRating
    }
}

final class PlaceListViewModel {
    @Published var placeCellViewModels: [PlaceCellViewModel] = []
    private var cancellables = Set<AnyCancellable>()
    private let useCase: HomeViewUseCase
    private let bookmarkApi: BookmarkApiProtocol
    
    @Published var places: [Place] = []
    
    init(useCase: HomeViewUseCase, bookmarkApi: BookmarkApiProtocol) {
            self.useCase = useCase
            self.bookmarkApi = bookmarkApi
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
                        for (index, viewModel) in cellViewModels.enumerated() {
                            print("Place \(index): ID = \(viewModel.id), isBookmarked = \(viewModel.isBookmarked)")
                        }
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
                            //print("Received places: \(cellViewModels.count)")
                            self?.placeCellViewModels = cellViewModels
                        }
            .store(in: &cancellables)
    }
    
    func toggleBookmark(at index: Int) {
        print("toggleBookmark called with index: \(index)")
        guard index < placeCellViewModels.count else {
            print("Index out of range: \(index), placeCellViewModels count: \(placeCellViewModels.count)")
            return
        }
        let placeId = placeCellViewModels[index].id
        let currentIsBookmarked = placeCellViewModels[index].isBookmarked
        
        print("Toggling bookmark for placeId: \(placeId), current state: \(currentIsBookmarked)")
        
        bookmarkApi.toggleBookmark(placeId: placeId)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Error toggling bookmark: \(error)")
                    }
                } receiveValue: { [weak self] serverIsBookmarked in
                    print("Server confirmed bookmark state: \(serverIsBookmarked)")
                    let newIsBookmarked = !currentIsBookmarked
                    print("Local bookmark state changed to: \(newIsBookmarked)")
                    if serverIsBookmarked == newIsBookmarked {
                        print("Server and local state are in sync")
                    } else {
                        print("Warning: Server and local state are out of sync")
                    }
                    self?.placeCellViewModels[index].isBookmarked = newIsBookmarked
                    //self?.objectWillChange.send()
                }
                .store(in: &cancellables)
    }
}
