//
//  WeatherViewController.swift
//  Busanify
//
//  Created by 장예진 on 7/8/24.
//

// -TODO: 지도 이미지 단순하게 선따기
// -TODO: 좌표 연결해서 버튼 생성하기
// -TODO: 버튼 누르면 날씨 상세 모달뷰 뜨도록

import UIKit
import WeatherKit
import CoreLocation

class WeatherViewController: UIViewController, WeatherManagerDelegate {
    private let weatherManager = WeatherManager()
    private let geocoder = CLGeocoder()
    private let weatherLabel = UILabel()
    private let locationLabel = UILabel()
    private let maxMinTempLabel = UILabel()
    private let avgTempLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        weatherManager.delegate = self
        weatherManager.startFetchingWeather()
    }
    
    private func setupNavigationBar() {
        self.title = "날씨"
        self.navigationController?.navigationBar.barTintColor = .white
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle("back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupUI() {
        view.backgroundColor = .white

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        locationLabel.textAlignment = .center
        locationLabel.text = "Loading..."
        view.addSubview(locationLabel)
        
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherLabel.textAlignment = .center
        weatherLabel.numberOfLines = 0
        view.addSubview(weatherLabel)
        
        maxMinTempLabel.translatesAutoresizingMaskIntoConstraints = false
        maxMinTempLabel.textAlignment = .center
        view.addSubview(maxMinTempLabel)
        
        avgTempLabel.translatesAutoresizingMaskIntoConstraints = false
        avgTempLabel.textAlignment = .center
        view.addSubview(avgTempLabel)
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weatherLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            weatherLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weatherLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            maxMinTempLabel.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 20),
            maxMinTempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
        ])
    }
    
    func didUpdateWeather(_ weather: Weather) {
        DispatchQueue.main.async {
            if let location = self.weatherManager.locationManager.location {
                self.geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    if let placemark = placemarks?.first {
                        self.locationLabel.text = "📍 \(placemark.locality ?? "Unknown Location")"
                    } else {
                        self.locationLabel.text = "📍 Unknown Location"
                    }
                }
            }
            
            let temperature = weather.currentWeather.temperature.value
            self.weatherLabel.text = "Temperature: \(temperature)°C"
            
            let maxTemp = weather.dailyForecast.first?.highTemperature.value ?? 0.0
            let minTemp = weather.dailyForecast.first?.lowTemperature.value ?? 0.0
            self.maxMinTempLabel.text = "Max: \(maxTemp)°C / Min: \(minTemp)°C"
        
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            self.locationLabel.text = "Failed to get location"
            self.weatherLabel.text = "Failed to get weather: \(error.localizedDescription)"
            self.maxMinTempLabel.text = ""
        }
    }
}
