//
//  PlaceApi.swift
//  Busanify
//
//  Created by 이인호 on 6/23/24.
//

import Foundation
import Combine

final class PlacesApi: HomeViewUseCase, PlaceDetailViewUseCase {
    private let baseURL: String
    
    init() {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL not set in plist")
        }
        self.baseURL = baseURL
    }
    
    func getPlaces(by typeId: PlaceType, lang: String, lat: Double, lng: Double, radius: Double) -> AnyPublisher<[Place], Never> {
        let urlString = "\(baseURL)/places/searchByType?typeId=\(typeId.rawValue)&lang=\(lang)&lat=\(lat)&lng=\(lng)&radius=\(radius)"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .handleEvents(receiveCompletion: {
                print($0)
            })
            .decode(type: [Place].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getPlaces(by title: String, lang: String) -> AnyPublisher<[Place], Never> {
        let urlString = "\(baseURL)/places/searchByTitle?title=\(title)&lang=\(lang)"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .handleEvents(receiveCompletion: {
                print($0)
            })
            .decode(type: [Place].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func getPlace(by id: Int, lang: String) -> AnyPublisher<Place, Never> {
        let urlString = "\(baseURL)/place?id=\(id)&lang=\(lang)"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Place.self, decoder: JSONDecoder())
            .replaceError(with: Place(id: "", typeId: "", image: "", lat: 0, lng: 0, tel: "", title: "", address: "", openTime: nil, parking: nil, holiday: nil, fee: nil, reservationURL: nil, goodStay: nil, hanok: nil, menu: nil, shopguide: nil, restroom: nil, isBookmarked: false, avgRating: 0.0))
            .eraseToAnyPublisher()
    }
    
    func toggleBookmark(placeId: String, token: String) -> AnyPublisher<Bool, Never> {
        let urlString = "\(baseURL)/bookmarks/toggle"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
    
    func getBookmarkedPlaces(token: String) -> AnyPublisher<[Place], Error> {
        let urlString = "\(baseURL)/bookmarks/user"
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { output in
                if let jsonString = String(data: output.data, encoding: .utf8) {
                    print("Received JSON: \(jsonString)")
                }
            })
            .map(\.data)
            .decode(type: [Place].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
