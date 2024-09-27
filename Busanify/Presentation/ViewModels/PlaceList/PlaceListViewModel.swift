//
//  PlaceListViewModel.swift
//  Busanify
//
//  Created by seokyung on 7/1/24.
//

import Foundation
import Combine

struct PlaceCellModel {
    let id: String
    let title: String
    let address: String
    let openTime: String?
    let imageURL: URL?
    var isBookmarked: Bool
    let avgRating: Double
    let reviewCount: Int
    
    init(place: Place) {
        self.id = place.id
        self.title = place.title
        self.address = place.address
        self.openTime = place.openTime.flatMap { $0.isEmpty ? nil : $0 }
        self.imageURL = URL(string: place.image)
        self.isBookmarked = place.isBookmarked
        self.avgRating = place.avgRating
        self.reviewCount = place.reviewCount ?? 0
    }
}

final class PlaceListViewModel {
    @Published var placeCellModels: [PlaceCellModel] = []
    private var cancellables = Set<AnyCancellable>()
    //    private let useCase: PlaceListViewUseCase
    private let placeAPI = PlacesApi()
    
    //    init(useCase: PlaceListViewUseCase) {
    //        self.useCase = useCase
    //    }
    
    func fetchPlaces(typeId: PlaceType, lang: String, lat: Double, lng: Double, radius: Double) {
        placeAPI.getPlaces(by: typeId, lang: lang, lat: lat, lng: lng, radius: radius)
            .map { places in places.map { PlaceCellModel(place: $0) } }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error fetching places: \(error)")
                }
            } receiveValue: { [weak self] cellViewModels in
                self?.placeCellModels = cellViewModels
                self?.syncBookmarksWithServer(lang: lang)
            }
            .store(in: &cancellables)
    }
    
    func toggleBookmark(at index: Int) async throws {
        guard index < placeCellModels.count,
              let token = AuthenticationViewModel.shared.getToken() else { return }
        
        let placeId = placeCellModels[index].id
        
        try await placeAPI.toggleBookmark(placeId: placeId, token: token)
    }
    
    func syncBookmarksWithServer(lang: String) {
        guard let token = AuthenticationViewModel.shared.getToken() else { return }
        
        placeAPI.getBookmarkedPlaces(token: token, lang: lang)
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
        placeCellModels = placeCellModels.map { viewModel in
            var updatedViewModel = viewModel
            updatedViewModel.isBookmarked = bookmarkedIds.contains(viewModel.id)
            return updatedViewModel
        }
    }
}
