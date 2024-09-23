//
//  PostViewModel.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import Foundation
import UIKit

final class PostViewModel {
    private let useCase: PostViewUseCase
    
    @Published var posts: [Post] = []
    
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
        useCase.getPosts()
            .receive(on: DispatchQueue.main)
            .assign(to: &$posts)
    }
    
    func updatePost(token: String?, id: Int, content: String, photos: [UIImage], existingImageUrls: [String]) async throws {
        guard let token = token else { return }
        var photoUrls: [String] = []
        
        for photo in photos {
            if let data = photo.jpegData(compressionQuality: 1.0) {
                let url = try await useCase.saveImage(data: data)
                photoUrls.append(url)
            }
        }
        
        let allImageUrls = existingImageUrls + photoUrls
        let updatePostDTO = UpdatePostDTO(id: id, content: content, photoUrls: allImageUrls)
        try await useCase.updatePost(token: token, updatePostDTO: updatePostDTO)
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
