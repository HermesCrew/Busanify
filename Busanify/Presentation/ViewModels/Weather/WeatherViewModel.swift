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
    @Published var selectedRegion: String?
    @Published var error: String?
    @Published var sortedHourlyForecast: [HourWeather] = []
    @Published var isCurrentLocation: Bool = true
    
    private let weatherManager = WeatherManager()
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    
    // (내 위치가 부산이 아닐 시) 홈 뷰와 같이 부산 서면으로 위치 고정
    private let pinLocation = CLLocation(latitude: 35.1577, longitude: 129.0595)
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        checkLocationAndFetchWeather(for: location)
    }
    
    private func checkLocationAndFetchWeather(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let placemark = placemarks?.first,
               let administrativeArea = placemark.administrativeArea {
                if administrativeArea == "부산광역시" {
                    self.fetchWeather(for: location, isCurrentLocation: true)
                } else {
                    self.fetchWeather(for: self.pinLocation, isCurrentLocation: false)
                }
            } else {
                self.fetchWeather(for: self.pinLocation, isCurrentLocation: false)
            }
        }
    }
    
    func fetchWeather(for location: CLLocation, isCurrentLocation: Bool) {
        Task {
            do {
                let weather = try await weatherManager.fetchWeather(for: location)
                DispatchQueue.main.async {
                    self.currentWeather = weather
                    self.sortHourlyForecast()
                    self.isCurrentLocation = isCurrentLocation
                }
                self.updateLocationName(for: location, isCurrentLocation: isCurrentLocation)
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    private func updateLocationName(for location: CLLocation, isCurrentLocation: Bool) {
        Task {
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    DispatchQueue.main.async {
                        if isCurrentLocation {
                            if let locality = placemark.locality,
                               let subLocality = placemark.subLocality {
                                self.selectedRegion = "\(locality) \(subLocality)"
                            } else if let locality = placemark.locality {
                                self.selectedRegion = locality
                            }
                        } else {
                            self.selectedRegion = "부산광역시 부산진구 서면"
                        }
                    }
                }
            } catch {
                print("Geocoding error: \(error.localizedDescription)")
            }
        }
    }
    
    func updateToCurrentLocation() {
        locationManager.startUpdatingLocation()
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
}

