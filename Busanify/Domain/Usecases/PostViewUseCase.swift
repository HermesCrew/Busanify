//
//  PostViewUseCase.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import Foundation
import Combine

protocol PostViewUseCase {
    func createPost(token: String, postDTO: PostDTO) async throws
    func saveImage(data: Data) async throws -> String
    func getPosts() -> AnyPublisher<[Post], Never>
    func reportPost(token: String, reportDTO: ReportDTO)
    func deletePost(by id: Int, token: String) async throws
    func deleteImage(imageUrl: String)
}
