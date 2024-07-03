//
//  HomeViewModel.swift
//  Busanify
//
//  Created by MadCow on 2024/6/24.
//

import Foundation
import CoreLocation
import Combine

class HomeViewModel {
    @Published var searchedPlaces: [Place] = []
    
    private let placeService = PlacesApi()
    private let locationManager = CLLocationManager()
    private var cancellable = Set<AnyCancellable>()
    var currentLong: CGFloat? = nil
    var currentLat: CGFloat? = nil
    
    init() {        
        if locationManager.authorizationStatus == .authorizedAlways ||
            locationManager.authorizationStatus == .authorizedWhenInUse {
            if let location = locationManager.location {
                currentLong = location.coordinate.longitude
                currentLat = location.coordinate.latitude
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getLocationsBy(keyword: String) {
        placeService.getPlaces(by: keyword, lang: "eng")
            .receive(on: DispatchQueue.global())
            .assign(to: &$searchedPlaces)
    }
}
