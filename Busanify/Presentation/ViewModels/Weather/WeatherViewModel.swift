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
            return forecast.date >= now && forecast.date < calendar.date(byAdding: .hour, value: 24, to: now)!
        }
        
        var sorted = filtered.sorted { $0.date < $1.date }
        
        // 현재 시간대에 있는 예보를 찾아 "지금"으로 표시하고 맨 앞으로 이동
        if let nowIndex = sorted.firstIndex(where: { calendar.isDate($0.date, equalTo: now, toGranularity: .hour) }) {
            var nowForecast = sorted.remove(at: nowIndex)
//            nowForecast.customLabel = "지금"?
            sorted.insert(nowForecast, at: 0)
        }
        
        sortedHourlyForecast = sorted
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
