//
//  WeatherManager.swift
//  Busanify
//
//  Created by 장예진 on 7/26/24.
//

import Foundation
import CoreLocation
import WeatherKit

protocol WeatherManagerDelegate: AnyObject {
    func didUpdateWeather(_ weather: Weather)
    func didFailWithError(_ error: Error)
}

class WeatherManager: NSObject, CLLocationManagerDelegate {
    let weatherService = WeatherService.shared
    weak var delegate: WeatherManagerDelegate?
    let locationManager = CLLocationManager()
    var currentWeather: Weather?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startFetchingWeather() {
        locationManager.startUpdatingLocation()
    }
    
    func fetchWeather(for location: CLLocation) async throws -> Weather {
        let weather = try await weatherService.weather(for: location)
        currentWeather = weather
        return weather
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task {
            do {
                let weather = try await fetchWeather(for: location)
                delegate?.didUpdateWeather(weather)
                locationManager.stopUpdatingLocation()
            } catch {
                delegate?.didFailWithError(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
}


