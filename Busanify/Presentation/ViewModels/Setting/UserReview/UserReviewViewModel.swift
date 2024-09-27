//
//  UserReviewViewModel.swift
//  Busanify
//
//  Created by seokyung on 9/27/24.
//

import Foundation
import Combine

class UserReviewViewModel {
    @Published var reviews: [Review] = []
    private let reviewApi = ReviewApi()
    private var cancellables = Set<AnyCancellable>()
    private var lang = "eng" // 사용자 언어
    init() {
        loadReviews()
    }
    
    func validateToken() -> String? {
        guard let token = AuthenticationViewModel.shared.getToken() else {
            print("No token available")
            return ""
        }
        return token
    }
    
    func loadReviews() {
        guard let token = AuthenticationViewModel.shared.getToken() else {
            print("No token available")
            return
        }
        
        reviewApi.getUserReviews(token: token, lang: lang)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading reviews: \(error)")
                }
            }, receiveValue: { [weak self] reviews in
                self?.reviews = reviews
                print(reviews)
            })
            .store(in: &cancellables)
    }
}
