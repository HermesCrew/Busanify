//
//  SignInApi.swift
//  Busanify
//
//  Created by 이인호 on 6/27/24.
//

import Foundation

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
    
    func saveAppleUser(code: String) {
        guard let authData = try? JSONEncoder().encode(["authorizationCode": code]) else {
            return
        }
        
        let urlString = "\(baseURL)/auth/apple/signin"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: authData) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "No data")")
                return
            }
            
            if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Response JSON: \(responseJSON)")
            } else {
                print("Invalid JSON response")
            }
        }
        
        task.resume()
    }
}
