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
import Combine
import CoreLocation

class WeatherViewController: UIViewController, WeatherFetcherDelegate {
    
    let locationLabel = UILabel()
    let temperatureLabel = UILabel()
    let minTempLabel = UILabel()
    let maxTempLabel = UILabel()
    let descriptionLabel = UILabel()
    let weatherIcon = UIImageView()
    let weatherFetcher = WeatherFetcher()
    var cancellables = Set<AnyCancellable>()
    var weatherData: WeatherData? // 추가: WeatherData 속성
    let mapView = UIImageView()
    
    // 좌표 데이터
    let regions = [
        ("강서구", 128.9829083, 35.20916389),
        ("금정구", 129.0943194, 35.24007778),
        ("남구", 129.0865, 35.13340833),
        ("동구", 129.059175, 35.13589444),
        ("동래구", 129.0858556, 35.20187222),
        ("부산진구", 129.0553194, 35.15995278),
        ("북구", 128.992475, 35.19418056),
        ("사상구", 128.9933333, 35.14946667),
        ("사하구", 128.9770417, 35.10142778),
        ("서구", 129.0263778, 35.09483611),
        ("수영구", 129.115375, 35.14246667),
        ("연제구", 129.082075, 35.17318611),
        ("영도구", 129.0701861, 35.08811667),
        ("중구", 129.0345083, 35.10321667),
        ("해운대구", 129.1658083, 35.16001944),
        ("기장군", 129.2222873, 35.24477541)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        weatherFetcher.delegate = self
        navigationItem.title = "날씨" // 내비게이션 타이틀 설정
        setupUI()
        addRegionLabels()
    }
    
    func setupUI() {
        mapView.image = UIImage(named: "busan_map")
        mapView.isUserInteractionEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
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
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 1.0),
            
            locationLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
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
    
    func addRegionLabels() {
        for (region, longitude, latitude) in regions {
            addRegionLabel(x: longitude, y: latitude, region: region)
        }
    }
    
    func addRegionLabel(x: Double, y: Double, region: String) {
        let label = UILabel()
        // 지도 이미지의 비율에 맞춰 라벨 위치 조정
        let mapWidth = mapView.frame.size.width
        let mapHeight = mapView.frame.size.height
        let adjustedX = mapWidth * (x - 128.9) / (129.2222873 - 128.9) // 경도 조정
        let adjustedY = mapHeight * (35.3 - y) / (35.3 - 35.08811667) // 위도 조정
        
        label.frame = CGRect(x: adjustedX, y: adjustedY, width: 80, height: 30)
        label.backgroundColor = .white
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = region
        
        // Tap gesture recognizer 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(regionLabelTapped(_:)))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        label.tag = region.hashValue
        
        mapView.addSubview(label)
    }
    
    @objc func regionLabelTapped(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let region = regions.first { $0.0.hashValue == label.tag }
        guard let regionName = region?.0 else { return }
        // 지역구에 따른 날씨 정보 요청 및 모달 뷰 표시
        fetchWeatherForRegion(regionName: regionName)
    }
    
    func fetchWeatherForRegion(regionName: String) {
        weatherFetcher.fetchWeather(for: regionName)
    }
    
    func showWeatherModal(with weatherData: WeatherData) {
        let weatherVC = WeatherViewController()
        weatherVC.weatherData = weatherData // 수정: weatherData 속성 설정
        weatherVC.modalPresentationStyle = .formSheet
        present(weatherVC, animated: true, completion: nil)
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
        
        URLSession.shared.dataTaskPublisher(for: URLRequest(url: iconUrl))
            .map(\.data)
            .compactMap { UIImage(data: $0) }
            .replaceError(with: UIImage())
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                self?.weatherIcon.image = image
            })
            .store(in: &cancellables)
    }
    
    func didFailWithError(_ error: Error) {
        print("Failed to fetch weather: \(error)")
    }
}
