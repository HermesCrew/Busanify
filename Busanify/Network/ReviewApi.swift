//
//  ReviewApi.swift
//  Busanify
//
//  Created by 이인호 on 9/15/24.
//

import Foundation
import Combine

final class ReviewApi: ReviewUseCase {
    private let baseURL: String
    var cancellables = Set<AnyCancellable>()
    
    init() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL not set in plist")
        }
        self.baseURL = baseURL
    }
    
    func reportReview(token: String, reportDTO: ReportDTO) {
        let urlString = "\(baseURL)/reports"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        guard let jsonData = try? JSONEncoder().encode(reportDTO) else {
            fatalError("Json Encode Error")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared.dataTaskPublisher(for: request)
            .sink(receiveCompletion: { _ in
                print("completion")
            }, receiveValue: {
                print($0)
            })
            .store(in: &cancellables)
    }
    
    func deleteReview(by id: Int, token: String) async throws {
        let urlString = "\(baseURL)/reviews"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        let json: [String: Int] = ["id": id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    
}
