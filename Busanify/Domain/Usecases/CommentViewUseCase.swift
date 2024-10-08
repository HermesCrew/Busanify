//
//  CommentViewUseCase.swift
//  Busanify
//
//  Created by 이인호 on 9/23/24.
//

import Foundation
import Combine

protocol CommentViewUseCase {
    func createComment(token: String, commentDTO: CommentDTO) async throws
    func getComments(postId: Int, token: String?) -> AnyPublisher<[Comment], Never>
    func deleteComment(by id: Int, token: String) async throws
    func reportComment(token: String, reportDTO: ReportDTO)
    func blockUserByComment(token: String, blockedUserId: String) async throws
}
