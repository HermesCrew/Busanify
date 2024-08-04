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
    
    var currentLong: CGFloat = 0
    var currentLat: CGFloat = 0
    private let placeService = PlacesApi()
    private let locationManager = CLLocationManager()
    private var cancellable = Set<AnyCancellable>()
    private let latRange = 34.8799083...35.3959361
    private let longRange = 128.7384361...129.3728194
    
    init() {
        if locationManager.authorizationStatus == .authorizedAlways ||
            locationManager.authorizationStatus == .authorizedWhenInUse {
            if let location = locationManager.location,
               longRange.contains(location.coordinate.longitude),
               latRange.contains(location.coordinate.latitude) {
                    currentLong = location.coordinate.longitude
                    currentLat = location.coordinate.latitude
            } else {
                // default(임시로 서면역으로 설정) 위, 경도
                currentLong = 129.0595
                currentLat = 35.1577
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getCurrentLocation() -> (CGFloat, CGFloat) {
        guard let location = locationManager.location else { return (0, 0) }
        if longRange.contains(location.coordinate.longitude),
           latRange.contains(location.coordinate.latitude) {
            return (location.coordinate.longitude, location.coordinate.latitude)
        } else {
            return (129.0595, 35.1577)
        }
    }
    
    func getLocationBy(typeId: PlaceType, lat: CGFloat, lng: CGFloat, radius: Double) {
        placeService.getPlaces(by: typeId, lang: "eng", lat: lat, lng: lng, radius: radius)
            .receive(on: DispatchQueue.global())
            .assign(to: &$searchedPlaces)
    }
    
    func getLocationsBy(keyword: String) {
        placeService.getPlaces(by: keyword, lang: "eng")
            .receive(on: DispatchQueue.global())
            .assign(to: &$searchedPlaces)
    }
}
