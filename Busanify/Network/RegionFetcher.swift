//
//  RegionFetcher.swift
//  Busanify
//
//  Created by 장예진 on 7/3/24.
//

// -MARK: have to connect the kakao x,y api
//
//import Foundation
//import Combine
//
//struct KakaoRegion: Codable {
//    let documents: [Document]
//    
//    struct Document: Codable {
//        let place_name: String
//        let x: String
//        let y: String
//    }
//}
//
//class RegionFetcher {
//    private let apiKey = "API_KEY"
//    private let baseUrl = "https://dapi.kakao.com/v2/local/search/address.json"
//    
//    func fetchRegions(for query: String) -> AnyPublisher<[KakaoRegion.Document], Error> {
//        var urlComponents = URLComponents(string: baseUrl)!
//        urlComponents.queryItems = [
//            URLQueryItem(name: "query", value: query)
//        ]
//        
//        var request = URLRequest(url: urlComponents.url!)
//        request.addValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
//        
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .map(\.data)
//            .decode(type: KakaoRegion.self, decoder: JSONDecoder())
//            .map { $0.documents }
//            .eraseToAnyPublisher()
//    }
//}
