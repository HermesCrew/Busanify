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
            .handleEvents(receiveOutput: { data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
            })
            .decode(type: Place.self, decoder: JSONDecoder())
            .replaceError(with: Place(id: -1, typeId: "", image: "", lat: 0, lng: 0, tel: "", title: "", address: "", openTime: nil, parking: nil, holiday: nil, fee: nil, reservationURL: nil, goodStay: nil, hanok: nil, menu: nil, shopguide: nil, restroom: nil))
            .eraseToAnyPublisher()
    }
}
