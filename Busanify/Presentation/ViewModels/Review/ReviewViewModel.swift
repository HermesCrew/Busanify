//
//  ReviewViewModel.swift
//  Busanify
//
//  Created by 이인호 on 9/15/24.
//

import Foundation

final class ReviewViewModel {
    private let useCase: ReviewUseCase
    
    init(useCase: ReviewUseCase) {
        self.useCase = useCase
    }
    
    func reportReview(token: String?, reportData: Report) {
        guard let token = token else { return }
        
        useCase.reportReview(token: token, reportData: reportData)
    }
    
    func deleteReview(id: Int, token: String?) async throws {
        guard let token = token else { return }
        
        try await useCase.deleteReview(by: id, token: token)
    }
}
