//
//  ReviewUseCase.swift
//  Busanify
//
//  Created by 이인호 on 9/15/24.
//

import Foundation
import Combine

protocol ReviewUseCase {
    func createReview(token: String, reviewDTO: ReviewDTO) async throws
    func updateReview(token: String, updateReviewDTO: UpdateReviewDTO) async throws
    func saveImage(data: Data) async throws -> String
    func reportReview(token: String, reportDTO: ReportDTO)
    func deleteReview(by id: Int, token: String) async throws
}
