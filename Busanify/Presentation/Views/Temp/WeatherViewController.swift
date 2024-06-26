//
//  WeatherViewController.swift
//  Busanify
//
//  Created by 장예진 on 6/25/24.
//

import UIKit

class WeatherViewController: UIViewController, WeatherFetcherDelegate {
    
    let locationLabel = UILabel()
    let temperatureLabel = UILabel()
    let minTempLabel = UILabel()
    let maxTempLabel = UILabel()
    let descriptionLabel = UILabel()
    let weatherIcon = UIImageView()
    let weatherFetcher = WeatherFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        weatherFetcher.delegate = self
        setupUI()
        weatherFetcher.startFetchingWeather()
    }
    
    func setupUI() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        locationLabel.textAlignment = .center
        view.addSubview(locationLabel)
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        temperatureLabel.textAlignment = .center
        view.addSubview(temperatureLabel)
        
        minTempLabel.translatesAutoresizingMaskIntoConstraints = false
        minTempLabel.font = UIFont.systemFont(ofSize: 20)
        minTempLabel.textAlignment = .center
        view.addSubview(minTempLabel)
        
        maxTempLabel.translatesAutoresizingMaskIntoConstraints = false
        maxTempLabel.font = UIFont.systemFont(ofSize: 20)
        maxTempLabel.textAlignment = .center
        view.addSubview(maxTempLabel)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 20)
        descriptionLabel.textAlignment = .center
        view.addSubview(descriptionLabel)
        
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.contentMode = .scaleAspectFit
        view.addSubview(weatherIcon)
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            temperatureLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            temperatureLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            maxTempLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 20),
            maxTempLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            maxTempLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            minTempLabel.topAnchor.constraint(equalTo: maxTempLabel.bottomAnchor, constant: 10),
            minTempLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            minTempLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: minTempLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            weatherIcon.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            weatherIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 100),
            weatherIcon.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func didUpdateWeather(_ weatherData: WeatherData) {
        locationLabel.text = weatherData.name
        temperatureLabel.text = "\(weatherData.main.temp)°C"
        minTempLabel.text = "Min: \(weatherData.main.temp_min)°C"
        maxTempLabel.text = "Max: \(weatherData.main.temp_max)°C"
        descriptionLabel.text = weatherData.weather.first?.description ?? ""
        
        let iconUrlString = "https://openweathermap.org/img/wn/\(weatherData.weather.first?.icon ?? "")@2x.png"
        guard let iconUrl = URL(string: iconUrlString) else {
            print("Invalid icon URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: iconUrl) { data, response, error in
            if let error = error {
                print("Error loading icon image: \(error)")
                return
            }
            
            guard let data = data, let iconImage = UIImage(data: data) else {
                print("No icon data returned or data is not an image")
                return
            }
            
            DispatchQueue.main.async {
                self.weatherIcon.image = iconImage
            }
        }
        
        task.resume()
    }
}
