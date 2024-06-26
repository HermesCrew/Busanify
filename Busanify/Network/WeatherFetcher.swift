//
//  WeatherFetcher.swift
//  Busanify
//
//  Created by 장예진 on 6/26/24.
//

import Foundation
import CoreLocation

protocol WeatherFetcherDelegate: AnyObject {
    func didUpdateWeather(_ weatherData: WeatherData)
}

class WeatherFetcher: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let apiKey = "YOUR_APIKEY"
    weak var delegate: WeatherFetcherDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startFetchingWeather() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        fetchWeather(for: location)
        locationManager.stopUpdatingLocation()
    }
    
    private func fetchWeather(for location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.delegate?.didUpdateWeather(weatherData)
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }
}

