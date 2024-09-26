//
//  PostViewModel.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import Foundation
import UIKit
import Combine

final class PostViewModel {
    private let useCase: PostViewUseCase
    
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: PostViewUseCase) {
        self.useCase = useCase
    }
    
    func createPost(token: String?, content: String, photos: [UIImage]) async throws {
        guard let token = token else { return }
        var photoUrls: [String] = []
        
        for photo in photos {
            if let data = photo.jpegData(compressionQuality: 1.0) {
                let url = try await useCase.saveImage(data: data)
                photoUrls.append(url)
            }
        }
        
        let postDTO = PostDTO(content: content, photoUrls: photoUrls)
        try await useCase.createPost(token: token, postDTO: postDTO)
    }
    
    func fetchPosts() {
        isLoading = true
        
        useCase.getPosts()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching posts: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] posts in
                self?.posts = posts
            })
            .store(in: &cancellables)
    }
    
    func updatePost(token: String?, id: Int, content: String, photos: [ImageData]) async throws -> [String] {
        guard let token = token else { return [] }
        var photoUrls: [String] = []
        
        for photo in photos {
            switch photo {
            case .image(let image):
                if let data = image.jpegData(compressionQuality: 1.0) {
                    let url = try await useCase.saveImage(data: data)
                    photoUrls.append(url)
                }
            case .url(let urlString):
                photoUrls.append(urlString)
                continue
            }
        }

        let updatePostDTO = UpdatePostDTO(id: id, content: content, photoUrls: photoUrls)
        try await useCase.updatePost(token: token, updatePostDTO: updatePostDTO)
        return photoUrls
    }
    
    func deletePost(token: String?, id: Int, photoUrls: [String]) async throws {
        guard let token = token else { return }
        
        try await useCase.deletePost(by: id, token: token)
        
        for photoUrl in photoUrls {
            useCase.deleteImage(imageUrl: photoUrl)
        }
    }
    
    func reportPost(token: String?, reportDTO: ReportDTO) {
        guard let token = token else { return }
        
        useCase.reportPost(token: token, reportDTO: reportDTO)
    }
}
