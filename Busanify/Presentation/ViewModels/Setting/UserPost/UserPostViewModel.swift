//
//  UserPostViewModel.swift
//  Busanify
//
//  Created by seokyung on 9/25/24.
//

import Foundation
import Combine

class UserPostViewModel {
    @Published var posts: [Post] = []
    private let postApi = PostApi()
    private var cancellables = Set<AnyCancellable>()
    init() {
        loadPosts()
    }
    
    func validateToken() -> String? {
        guard let token = AuthenticationViewModel.shared.getToken() else {
            print("No token available")
            return ""
        }
        return token
    }
    func loadPosts() {
        guard let token = AuthenticationViewModel.shared.getToken() else {
            print("No token available")
            return
        }
        
        postApi.getUserPosts(token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading bookmarks: \(error)")
                }
            }, receiveValue: { [weak self] posts in
                self?.posts = posts
            })
            .store(in: &cancellables)
    }
}
