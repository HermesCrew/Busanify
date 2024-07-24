//
//  PlaceListViewModel.swift
//  Busanify
//
//  Created by MadCow on 2024/7/21.
//

import UIKit
import Combine

class PlaceListViewModel {
    @Published private var places: [Place] = []
    @Published private var thumbnailImage: UIImage?
    
    func loadImage(url: String) async -> UIImage? {
        guard let url = URL(string: url) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("error in PlaceListViewModel: loadImage()\n->\(error.localizedDescription)")
        }
        return nil
    }
    
    func fetchPlaces() -> AnyPublisher<[Place], Never> {
        return self.$places
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }
    
    func setPlaces(places: [Place]) {
        self.places = places
    }
    
    func getPlaces() -> [Place] {
        return places
    }
}
