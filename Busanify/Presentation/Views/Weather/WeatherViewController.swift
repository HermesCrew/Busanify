//
//  WeatherViewController.swift
//  Busanify
//
//  Created by 장예진 on 7/8/24.
//

// TODO: 뷰 레퍼런스 탐색
// TODO:  좌표 별로 버튼 탭 하면 구별로 업데이트 가능하도록 하기
// TODO: 주 별 날씨 넣기
// TODO: 모달로  상세뷰 뜨게하기 ?

import UIKit
import WeatherKit
import CoreLocation

class WeatherViewController: UIViewController, WeatherManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    private let weatherManager = WeatherManager()
    private let geocoder = CLGeocoder()
    private let weatherLabel = UILabel()
    private let locationLabel = UILabel()
    private let maxMinTempLabel = UILabel()
    private let avgTempLabel = UILabel()
    private let weatherImageView = UIImageView()
    private let regionPickerView = UIPickerView()
    
    private let regions: [Region] = [
        Region(name: "강서구", latitude: 35.20916389, longitude: 128.9829083),
        Region(name: "금정구", latitude: 35.24007778, longitude: 129.0943194),
        Region(name: "남구", latitude: 35.13340833, longitude: 129.0865),
        Region(name: "동구", latitude: 35.13589444, longitude: 129.059175),
        Region(name: "동래구", latitude: 35.20187222, longitude: 129.0858556),
        Region(name: "부산진구", latitude: 35.15995278, longitude: 129.0553194),
        Region(name: "북구", latitude: 35.19418056, longitude: 128.992475),
        Region(name: "사상구", latitude: 35.14946667, longitude: 128.9933333),
        Region(name: "사하구", latitude: 35.10142778, longitude: 128.9770417),
        Region(name: "서구", latitude: 35.09483611, longitude: 129.0263778),
        Region(name: "수영구", latitude: 35.14246667, longitude: 129.115375),
        Region(name: "연제구", latitude: 35.17318611, longitude: 129.082075),
        Region(name: "영도구", latitude: 35.08811667, longitude: 129.0701861),
        Region(name: "중구", latitude: 35.10321667, longitude: 129.0345083),
        Region(name: "해운대구", latitude: 35.16001944, longitude: 129.1658083),
        Region(name: "기장군", latitude: 35.24477541, longitude: 129.2222873)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        weatherManager.delegate = self
        weatherManager.startFetchingWeather()
        
        regionPickerView.delegate = self
        regionPickerView.dataSource = self
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

        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        weatherImageView.contentMode = .scaleAspectFit
        view.addSubview(weatherImageView)

        regionPickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(regionPickerView)
        
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weatherLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            weatherLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weatherLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            weatherImageView.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 20),
            weatherImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherImageView.heightAnchor.constraint(equalToConstant: 100),
            weatherImageView.widthAnchor.constraint(equalToConstant: 100),
            
            maxMinTempLabel.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor, constant: 20),
            maxMinTempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            avgTempLabel.topAnchor.constraint(equalTo: maxMinTempLabel.bottomAnchor, constant: 20),
            avgTempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            regionPickerView.topAnchor.constraint(equalTo: avgTempLabel.bottomAnchor, constant: 20),
            regionPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            regionPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            regionPickerView.heightAnchor.constraint(equalToConstant: 150)
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
            
            let avgTemp = (maxTemp + minTemp) / 2.0
            self.avgTempLabel.text = "Average: \(avgTemp)°C"
            
            if let weatherImage = WeatherIcon.getWeatherIcon(for: weather.currentWeather) {
                self.weatherImageView.image = weatherImage
            } else {
                self.weatherImageView.image = UIImage(systemName: "questionmark.circle")
            }
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            self.locationLabel.text = "Failed to get location"
            self.weatherLabel.text = "Failed to get weather: \(error.localizedDescription)"
            self.maxMinTempLabel.text = ""
            self.avgTempLabel.text = ""
            self.weatherImageView.image = UIImage(systemName: "xmark.octagon")
        }
    }

    // UIPickerView DataSource and Delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regions[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRegion = regions[row]
        let location = CLLocation(latitude: selectedRegion.latitude, longitude: selectedRegion.longitude)
        
        Task {
            do {
                let weather = try await weatherManager.fetchWeather(for: location)
                self.didUpdateWeather(weather)
            } catch {
                self.didFailWithError(error)
            }
        }
    }
}
