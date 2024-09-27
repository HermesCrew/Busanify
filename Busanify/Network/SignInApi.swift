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
    var cancellables = Set<AnyCancellable>()
    
    init() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL not set in plist")
        }
        self.baseURL = baseURL
    }
    
    func saveGoogleUser(idToken: String) -> AnyPublisher<User?, Never> {
        guard let authData = try? JSONEncoder().encode(["idToken": idToken]) else {
            fatalError("Json Encode Error")
        }
        
        let urlString = "\(baseURL)/auth/google/signin"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = authData
        
        return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: User?.self, decoder: JSONDecoder())
                .replaceError(with: nil)
                .eraseToAnyPublisher()
    }
    
    func saveAppleUser(code: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let authData = try? JSONEncoder().encode(["authorizationCode": code]) else {
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
    
    func getUserProfile(token: String) -> AnyPublisher<User?, Never> {
        let urlString = "\(baseURL)/auth/profile"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: User?.self, decoder: JSONDecoder())
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func updateUserProfile(token: String, profileImage: String?, nickname: String?) -> AnyPublisher<User?, Never> {
        guard let jsonData = try? JSONEncoder().encode(["profileImage": profileImage, "nickname": nickname]) else {
            fatalError("Json Encode Error")
        }
        
        let urlString = "\(baseURL)/auth/updateProfile"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: User?.self, decoder: JSONDecoder())
                .replaceError(with: nil)
                .eraseToAnyPublisher()
    }
    
    func deleteUser(token: String, providerToDelete: String, completion: @escaping (Bool) -> Void) {
        let urlString = "\(baseURL)/auth/\(providerToDelete)"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
        
        task.resume()
    }
}
