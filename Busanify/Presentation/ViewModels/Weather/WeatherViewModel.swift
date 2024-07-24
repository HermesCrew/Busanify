//
//  WeatherViewModel.swift
//  Busanify
//
//  Created by 장예진 on 7/24/24.
//

import Foundation
import CoreLocation
import WeatherKit
import UIKit

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentWeather: Weather?
    @Published var locationName: String = "Loading..."
    @Published var error: String?
    
    private let weatherManager = WeatherManager()
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func fetchWeather(for location: CLLocation) {
        Task {
            do {
                let weather = try await weatherManager.fetchWeather(for: location)
                DispatchQueue.main.async {
                    self.currentWeather = weather
                }
                do {
                    let placemarks = try await geocoder.reverseGeocodeLocation(location)
                    if let placemark = placemarks.first {
                        DispatchQueue.main.async {
                            self.locationName = "📍 \(placemark.locality ?? "Unknown Location")"
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.locationName = "📍 Unknown Location"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.locationName = "📍 Unknown Location"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        fetchWeather(for: location)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.error = error.localizedDescription
        }
    }
}
