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
    
    func fetchComments(postId: Int) {
        useCase.getComments(postId: postId)
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
}
