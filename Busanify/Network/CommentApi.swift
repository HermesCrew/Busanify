//
//  CommentApi.swift
//  Busanify
//
//  Created by 이인호 on 9/23/24.
//

import Foundation
import Combine

final class CommentApi: CommentViewUseCase {
    private let baseURL: String
    var cancellables = Set<AnyCancellable>()
    
    init() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL not set in plist")
        }
        self.baseURL = baseURL
    }
    
    func createComment(token: String, commentDTO: CommentDTO) async throws {
        let urlString = "\(baseURL)/comments"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        guard let jsonData = try? JSONEncoder().encode(commentDTO) else {
            fatalError("Json Encode Error")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    func getComments(postId: Int, token: String) -> AnyPublisher<[Comment], Never> {
        let urlString = "\(baseURL)/comments/post/\(postId)"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .handleEvents(receiveCompletion: {
                print($0)
            })
            .decode(type: [Comment].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func deleteComment(by id: Int, token: String) async throws {
        let urlString = "\(baseURL)/comments"
        
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
    
    func reportComment(token: String, reportDTO: ReportDTO) {
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
    
    func blockUserByComment(token: String, blockedUserId: String) async throws {
        let urlString = "\(baseURL)/block"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let jsonData = try JSONEncoder().encode(["blockedUserId": blockedUserId])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}
