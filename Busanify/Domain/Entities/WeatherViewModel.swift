//
//  WeatherViewModel.swift
//  Busanify
//
//  Created by 장예진 on 7/26/24.
//

import Foundation
import CoreLocation
import WeatherKit
import UIKit

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentWeather: Weather?
    @Published var selectedRegion: String = "전체"
    @Published var error: String?
    @Published var sortedHourlyForecast: [HourWeather] = []
    @Published var isCurrentLocation: Bool = true
    
    private let weatherManager = WeatherManager()
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func fetchWeather(for location: CLLocation, isCurrentLocation: Bool = false) {
        Task {
            do {
                let weather = try await weatherManager.fetchWeather(for: location)
                DispatchQueue.main.async {
                    self.currentWeather = weather
                    self.sortHourlyForecast()
                    self.isCurrentLocation = isCurrentLocation
                }
                if isCurrentLocation {
                    do {
                        let placemarks = try await geocoder.reverseGeocodeLocation(location)
                        if let placemark = placemarks.first, let locality = placemark.locality {
                            DispatchQueue.main.async {
                                self.selectedRegion = locality
                            }
                        }
                    } catch {
                        print("Geocoding error: \(error.localizedDescription)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    private func sortHourlyForecast() {
        guard let weather = currentWeather else { return }
        
        let now = Date()
        let calendar = Calendar.current
        
        let filtered = weather.hourlyForecast.filter { forecast in
            let startOfCurrentHour = calendar.date(bySettingHour: calendar.component(.hour, from: now), minute: 0, second: 0, of: now)!
            return forecast.date >= startOfCurrentHour && forecast.date < calendar.date(byAdding: .hour, value: 24, to: startOfCurrentHour)!
        }
        
        sortedHourlyForecast = filtered.sorted { $0.date < $1.date }
    }
    
    func updateToCurrentLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        fetchWeather(for: location, isCurrentLocation: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.error = error.localizedDescription
        }
    }
}

