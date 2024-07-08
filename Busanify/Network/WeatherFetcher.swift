//
//  WeatherFetcher.swift
//  Busanify
//
//  Created by 장예진 on 7/8/24.
//

import Foundation
import CoreLocation
import Combine

protocol WeatherFetcherDelegate: AnyObject {
    func didUpdateWeather(_ weatherData: WeatherData)
    func didFailWithError(_ error: Error)
}

class WeatherFetcher: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let apiKey: String
    weak var delegate: WeatherFetcherDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "WEATHER_KEY") as? String else {
            fatalError("API Key is missing in Info.plist")
        }
        self.apiKey = apiKey
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startFetchingWeather() {
        locationManager.startUpdatingLocation()
    }
    
    func fetchWeather(for region: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather"
        let parameters: [String: Any] = [
            "q": region,
            "appid": apiKey,
            "units": "metric"
        ]
        
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        
        guard let url = urlComponents.url else { return }
        
        URLSession.shared.dataTaskPublisher(for: URLRequest(url: url))
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.delegate?.didFailWithError(error)
                }
            }, receiveValue: { weatherData in
                DispatchQueue.main.async {
                    self.delegate?.didUpdateWeather(weatherData)
                }
            })
            .store(in: &cancellables)
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
        
        URLSession.shared.dataTaskPublisher(for: URLRequest(url: url))
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.delegate?.didFailWithError(error)
                }
            }, receiveValue: { weatherData in
                DispatchQueue.main.async {
                    self.delegate?.didUpdateWeather(weatherData)
                }
            })
            .store(in: &cancellables)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
}
