//
//  SignInApi.swift
//  Busanify
//
//  Created by 이인호 on 6/27/24.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

final class SignInApi {
    private let baseURL: String
    
    init() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL not set in plist")
        }
        self.baseURL = baseURL
    }
    
    func saveGoogleUser(idToken: String) {
        guard let authData = try? JSONEncoder().encode(["idToken": idToken]) else {
            return
        }
        
        let urlString = "\(baseURL)/auth/google/signin"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: authData) { data, response, error in
        }
        
        task.resume()
    }
    
    func saveAppleUser(code: String, username: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let authData = try? JSONEncoder().encode(["authorizationCode": code, "username": username]) else {
            return
        }
        
        let urlString = "\(baseURL)/auth/apple/signin"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: authData) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData))
                return
            }
            
            if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String], let accessToken = responseJSON["accessToken"] {
                completion(.success(accessToken))
            } else {
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
    
    func getAppleUserProfile(accessToken: String) -> AnyPublisher<User, Never> {
        let urlString = "\(baseURL)/auth/apple/profile"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: User.self, decoder: JSONDecoder())
            .replaceError(with: User(id: "", email: "", name: "", profileImage: Data()))
            .eraseToAnyPublisher()
    }
}
