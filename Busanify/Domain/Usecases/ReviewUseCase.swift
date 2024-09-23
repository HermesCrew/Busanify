//
//  ReviewUseCase.swift
//  Busanify
//
//  Created by 이인호 on 9/15/24.
//

import Foundation
import Combine

protocol ReviewUseCase {
    func reportReview(token: String, reportDTO: ReportDTO)
    func deleteReview(by id: Int, token: String) async throws
}
