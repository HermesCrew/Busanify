//
//  HomeViewModel.swift
//  Busanify
//
//  Created by MadCow on 2024/6/24.
//

import Foundation
import CoreLocation

class HomeViewModel {
    private let placeService = PlacesApi()
    private let locationManager = CLLocationManager()
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
}
