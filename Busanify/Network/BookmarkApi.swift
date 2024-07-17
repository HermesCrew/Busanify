//
//  BookmarkApi.swift
//  Busanify
//
//  Created by seokyung on 7/12/24.
//

import Foundation
import Combine

protocol BookmarkApiProtocol {
    func toggleBookmark(placeId: String) -> AnyPublisher<Bool, Never>
}

final class BookmarkApi: BookmarkApiProtocol {
    private let baseURL: String
    
    init() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL not set in plist")
        }
        self.baseURL = baseURL
    }
    
    func toggleBookmark(placeId: String) -> AnyPublisher<Bool, Never> {
        let urlString = "\(baseURL)/bookmarks/toggle"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["placeId": placeId]
        request.httpBody = try? JSONEncoder().encode(body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .handleEvents(receiveOutput: { data in
                print("Received raw data from server: \(String(data: data, encoding: .utf8) ?? "")")
            })
            .decode(type: BookmarkResponse.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { response in
                print("Server response for bookmark toggle: \(response.isBookmarked)")
            })
            .map { $0.isBookmarked }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
