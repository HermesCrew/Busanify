//
//  PostApi.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import Foundation
import Combine
import FirebaseStorage

final class PostApi: PostViewUseCase {
    private let baseURL: String
    private let storage = Storage.storage().reference()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL not set in plist")
        }
        self.baseURL = baseURL
    }
    
    func createPost(token: String, postDTO: PostDTO) async throws {
        let urlString = "\(baseURL)/posts"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        guard let jsonData = try? JSONEncoder().encode(postDTO) else {
            fatalError("Json Encode Error")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    func saveImage(data: Data) async throws -> String {
        let path = UUID().uuidString
        let fileReference = storage.child(path)
        
        _ = try await fileReference.putDataAsync(data)
        
        let downloadUrl = try await fileReference.downloadURL()
        
        return downloadUrl.absoluteString
    }
    
    func getPosts() -> AnyPublisher<[Post], Never> {
        let urlString = "\(baseURL)/posts"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .handleEvents(receiveCompletion: {
                print($0)
            })
            .decode(type: [Post].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func updatePost(token: String, updatePostDTO: UpdatePostDTO) async throws {
        let urlString = "\(baseURL)/posts"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        guard let jsonData = try? JSONEncoder().encode(updatePostDTO) else {
            fatalError("Json Encode Error")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    func deletePost(by id: Int, token: String) async throws {
        let urlString = "\(baseURL)/posts"
        
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
    
    func deleteImage(imageUrl: String) {
        let imageRef = Storage.storage().reference(forURL: imageUrl)
        imageRef.delete { error in
            if let error = error {
                return
            }
        }
    }
    
    func reportPost(token: String, reportDTO: ReportDTO) {
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
}
