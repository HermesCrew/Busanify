//
//  WeatherViewController.swift
//  Busanify
//
//  Created by 장예진 on 7/8/24.
//

// MARK: 네비게이션 컨트롤러 Nil인 이슈로 인해 잠깐 모달뷰로 뷰 작업해놓음

// -TODO: 지도 이미지 단순하게 선따기
// -TODO: 좌표 연결해서 버튼 생성하기
// -TODO: 버튼 누르면 날씨 상세 모달뷰 뜨도록


import UIKit
import Combine
import CoreLocation

class WeatherViewController: UIViewController, WeatherFetcherDelegate {
    
    let mapView = UIImageView()
    let detailsView = UIView()
    let locationLabel = UILabel()
    let temperatureLabel = UILabel()
    let weatherIcon = UIImageView()
    let weatherFetcher = WeatherFetcher()
    var cancellables = Set<AnyCancellable>()
    
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
        weatherFetcher.startFetchingWeather() // 날씨 정보 가져오기 시작
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addRegionButtons() // 이미지 뷰의 크기와 위치가 설정된 후에 버튼 추가
    }
    
    func setupUI() {
        mapView.image = UIImage(named: "busan_map")
        mapView.isUserInteractionEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        detailsView.backgroundColor = .white
        detailsView.layer.cornerRadius = 10
        detailsView.layer.shadowColor = UIColor.black.cgColor
        detailsView.layer.shadowOpacity = 0.1
        detailsView.layer.shadowOffset = CGSize(width: 0, height: 1)
        detailsView.layer.shadowRadius = 4
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailsView)
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        locationLabel.textAlignment = .center
        detailsView.addSubview(locationLabel)
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        temperatureLabel.textAlignment = .center
        detailsView.addSubview(temperatureLabel)
        
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.contentMode = .scaleAspectFit
        detailsView.addSubview(weatherIcon)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 1.0),
            
            detailsView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            detailsView.heightAnchor.constraint(equalToConstant: 200),
            
            locationLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 20),
            locationLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor),
            
            temperatureLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            temperatureLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor),
            
            weatherIcon.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 20),
            weatherIcon.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 50),
            weatherIcon.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func addRegionButtons() {
        var previousButton: UIButton? = nil
        
        for (region, longitude, latitude) in regions {
            let button = UIButton()
            button.setTitle(region, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.addTarget(self, action: #selector(regionButtonTapped(_:)), for: .touchUpInside)
            
            // 지도 이미지의 비율에 맞춰 버튼 위치 조정
            let mapWidth = mapView.frame.size.width
            let mapHeight = mapView.frame.size.height
            let adjustedX = mapWidth * (longitude - 128.9) / (129.2222873 - 128.9) // 경도 조정
            let adjustedY = mapHeight * (35.3 - latitude) / (35.3 - 35.08811667) // 위도 조정
            
            button.frame = CGRect(x: adjustedX, y: adjustedY, width: 80, height: 30)
            
            // 버튼이 겹치지 않도록 위치 조정
            if let previousButton = previousButton {
                if button.frame.intersects(previousButton.frame) {
                    button.frame.origin.y += 35 // 이전 버튼과 겹칠 경우 y 위치 조정
                }
            }
            
            previousButton = button
            mapView.addSubview(button)
        }
    }
    
    @objc func regionButtonTapped(_ sender: UIButton) {
        guard let regionName = sender.title(for: .normal) else { return }
        // 버튼 색상 변경
        sender.backgroundColor = .gray
        fetchWeatherForRegion(regionName: regionName)
    }
    
    func fetchWeatherForRegion(regionName: String) {
        weatherFetcher.fetchWeather(for: regionName)
    }
    
    func didUpdateWeather(_ weatherData: WeatherData) {
        DispatchQueue.main.async {
            self.locationLabel.text = weatherData.name
            self.temperatureLabel.text = "\(Int(weatherData.main.temp))°C"
            
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
                .store(in: &self.cancellables)
        }
    }
    
    func didFailWithError(_ error: Error) {
        print("Failed to fetch weather: \(error)")
    }
}
