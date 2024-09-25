//
//  BookmarkViewModel.swift
//  Busanify
//
//  Created by seokyung on 9/24/24.
//

import Foundation
import Combine

class BookmarkViewModel {
    @Published var bookmarks: [Bookmark] = []
    @Published var isLoading: Bool = false
    private var bookmarkedIds: Set<String> = []
    private let placeApi = PlacesApi()
    private let lang = "eng"  // 임시
    private var cancellables = Set<AnyCancellable>()
    
    func loadBookmarks() {
        guard let token = AuthenticationViewModel.shared.getToken() else {
            bookmarks.removeAll()
            return
        }
        
        isLoading = true
        
        placeApi.getBookmarkedPlaces(token: token, lang: lang)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            })
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading bookmarks: \(error)")
                }
            }, receiveValue: { [weak self] bookmarks in
                self?.bookmarks = bookmarks
                self?.bookmarkedIds = Set(bookmarks.map { $0.id })
            })
            .store(in: &cancellables)
    }
    
    func toggleBookmark(at index: Int) async throws {
        guard index < bookmarks.count,
              let token = AuthenticationViewModel.shared.getToken() else { return }
        
        let placeId = bookmarks[index].id
        
        try await placeApi.toggleBookmark(placeId: placeId, token: token)
        
        if bookmarkedIds.contains(placeId) {
            bookmarkedIds.remove(placeId)
        } else {
            bookmarkedIds.insert(placeId)
        }
    }
    
    func isBookmarked(_ id: String) -> Bool {
        return bookmarkedIds.contains(id)
    }
}
