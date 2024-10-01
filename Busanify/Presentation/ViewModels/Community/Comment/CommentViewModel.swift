//
//  CommentViewModel.swift
//  Busanify
//
//  Created by 이인호 on 9/23/24.
//

import Foundation

final class CommentViewModel {
    private let useCase: CommentViewUseCase
    
    @Published var comments: [Comment] = []
    
    init(useCase: CommentViewUseCase) {
        self.useCase = useCase
    }
    
    func createComment(token: String?, postId: Int, content: String) async throws {
        guard let token = token else { return }
        
        let commentDTO = CommentDTO(postId: postId, content: content)
        try await useCase.createComment(token: token, commentDTO: commentDTO)
    }
    
    func fetchComments(postId: Int, token: String?) {
        guard let token = token else { return }
        
        useCase.getComments(postId: postId, token: token)
            .receive(on: DispatchQueue.main)
            .assign(to: &$comments)
    }
    
    func deleteComment(token: String?, id: Int) async throws {
        guard let token = token else { return }
        
        try await useCase.deleteComment(by: id, token: token)
    }
    
    func reportComment(token: String?, reportDTO: ReportDTO) {
        guard let token = token else { return }
        
        useCase.reportComment(token: token, reportDTO: reportDTO)
    }
    
    func blockUserByComment(token: String?, blockedUserId: String) async throws {
        guard let token = token else { return }
        
        try await useCase.blockUserByComment(token: token, blockedUserId: blockedUserId)
    }
}
