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
    let avgRating: Double
    
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
    
    init(useCase: HomeViewUseCase) {
        self.useCase = useCase
    }
    
    func fetchPlaces(typeId: PlaceType, lang: String, lat: Double, lng: Double, radius: Double) {
        useCase.getPlaces(by: typeId, lang: lang, lat: lat, lng: lng, radius: radius)
            .map { places in places.map { PlaceCellViewModel(place: $0) } }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error fetching places: \(error)")
                }
            } receiveValue: { [weak self] cellViewModels in
                self?.placeCellViewModels = cellViewModels
                self?.syncBookmarksWithServer(lang: lang)
            }
            .store(in: &cancellables)
    }
    
    func toggleBookmark(at index: Int) {
        guard index < placeCellViewModels.count,
              let token = AuthenticationViewModel.shared.getToken() else { return }
        
        let placeId = placeCellViewModels[index].id
        
        guard let placesApi = useCase as? PlacesApi else { return }
        
        placeCellViewModels[index].isBookmarked.toggle()
        
        placesApi.toggleBookmark(placeId: placeId, token: token)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error syncing bookmarks: \(error)")
                    self.placeCellViewModels[index].isBookmarked.toggle()
                }
            } receiveValue: { [weak self] isBookmarked in
                self?.placeCellViewModels[index].isBookmarked = isBookmarked
            }
            .store(in: &cancellables)
    }
    
    func syncBookmarksWithServer(lang: String) {
            guard let token = AuthenticationViewModel.shared.getToken() else { return }
            
            guard let placesApi = useCase as? PlacesApi else {
                print("Error: UseCase is not PlacesApi")
                return
            }
            
            placesApi.getBookmarkedPlaces(token: token, lang: lang)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Error syncing bookmarks: \(error)")
                    }
                } receiveValue: { [weak self] bookmarkedPlaces in
                    self?.updateBookmarkStatus(with: bookmarkedPlaces)
                }
                .store(in: &cancellables)
        }
        
        private func updateBookmarkStatus(with bookmarkedPlaces: [Bookmark]) {
            let bookmarkedIds = Set(bookmarkedPlaces.map { $0.id })
            placeCellViewModels = placeCellViewModels.map { viewModel in
                var updatedViewModel = viewModel
                updatedViewModel.isBookmarked = bookmarkedIds.contains(viewModel.id)
                return updatedViewModel
            }
        }
}
