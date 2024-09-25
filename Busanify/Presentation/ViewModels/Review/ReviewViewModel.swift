import UIKit

final class ReviewViewModel {
    private let useCase: ReviewUseCase
    
    init(useCase: ReviewUseCase) {
        self.useCase = useCase
    }
    
    func createReview(token: String?, content: String, rating: Double, photos: [UIImage]) async throws  {
        guard let token = token else { return }
        var photoUrls: [String] = []
        
        for photo in photos {
            if let data = photo.jpegData(compressionQuality: 1.0) {
                let url = try await useCase.saveImage(data: data)
                photoUrls.append(url)
            }
        }
        
        let reviewDTO = ReviewDTO(rating: rating, content: content, photoUrls: photoUrls)
        try await useCase.createReview(token: token, reviewDTO: reviewDTO)
    }
    
    func reportReview(token: String?, reportDTO: ReportDTO) {
        guard let token = token else { return }
        
        useCase.reportReview(token: token, reportDTO: reportDTO)
    }
    
    func deleteReview(id: Int, token: String?) async throws {
        guard let token = token else { return }
        
        try await useCase.deleteReview(by: id, token: token)
    }
}
