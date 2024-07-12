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
    
    let mapView = UIImageView()
    let detailsView = UIView()
    let locationLabel = UILabel()
    let temperatureLabel = UILabel()
    let weatherIcon = UIImageView()
    let locationIcon = UIImageView(image: UIImage(systemName: "location.fill"))
    let maxTempLabel = UILabel()
    let rainChanceLabel = UILabel()
    let weatherFetcher = WeatherFetcher()
    var cancellables = Set<AnyCancellable>()
    var selectedButton: UIButton?

    // 좌표: (x, y, width, height)
    let regions = [
        ("기장군", 874, 684, 156, 52),
        ("금정구", 632, 746, 124, 50),
        ("북구", 482, 858, 106, 40),
        ("강서구", 168, 1050, 160, 62),
        ("사하구", 326, 1274, 144, 64),
        ("사상구", 394, 1050, 94, 56),
        ("부산진구", 528, 1022, 98, 48),
        ("서구", 460, 1208, 80, 48),
        ("동구", 536, 1094, 106, 54),
        ("중구", 560, 1180, 124, 50),
        ("영도구", 628, 1304, 148, 48),
        ("남구", 718, 1138, 104, 42),
        ("해운대구", 832, 930, 174, 56),
        ("동래구", 620, 906, 118, 32),
        ("연제구", 648, 978, 126, 48),
        ("수영구", 760, 1050, 120, 56)
    ]

    var selectedRegionName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        weatherFetcher.delegate = self
        setupNavigationBar()
        setupUI()
        weatherFetcher.startFetchingWeather()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "날씨"
        navigationController?.isNavigationBarHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        if let navigationController = navigationController {
            navigationController.navigationBar.tintColor = .black
            navigationController.navigationBar.barTintColor = .white
            navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        } else {
            print("No navigation controller found")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addRegionButtons()
    }
    
    func setupUI() {
        mapView.image = UIImage(named: "busan")
        mapView.isUserInteractionEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        // 그림자 설정 추가
        mapView.layer.shadowColor = UIColor.black.cgColor
        mapView.layer.shadowOpacity = 0.3
        mapView.layer.shadowOffset = CGSize(width: 0, height: 1)
        mapView.layer.shadowRadius = 8
        
        view.addSubview(mapView)
        
        detailsView.backgroundColor = .white
        detailsView.layer.cornerRadius = 10
        detailsView.layer.shadowColor = UIColor.black.cgColor
        detailsView.layer.shadowOpacity = 0.3
        detailsView.layer.shadowOffset = CGSize(width: 0, height: 1)
        detailsView.layer.shadowRadius = 8
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailsView)
        
        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.tintColor = .gray
        detailsView.addSubview(locationIcon)
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        locationLabel.textAlignment = .left
        detailsView.addSubview(locationLabel)
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.font = UIFont.systemFont(ofSize: 45, weight: .bold)
        temperatureLabel.textAlignment = .left
        detailsView.addSubview(temperatureLabel)
        
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.contentMode = .scaleAspectFit
        detailsView.addSubview(weatherIcon)
        
        maxTempLabel.translatesAutoresizingMaskIntoConstraints = false
        maxTempLabel.font = UIFont.systemFont(ofSize: 14)
        maxTempLabel.textColor = .gray
        maxTempLabel.textAlignment = .left
        detailsView.addSubview(maxTempLabel)
        
        rainChanceLabel.translatesAutoresizingMaskIntoConstraints = false
        rainChanceLabel.font = UIFont.systemFont(ofSize: 14)
        rainChanceLabel.textColor = .gray
        rainChanceLabel.textAlignment = .left
        detailsView.addSubview(rainChanceLabel)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.8),
            
            detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            detailsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            detailsView.heightAnchor.constraint(equalToConstant: 200),

            locationIcon.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 20),
            locationIcon.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 20),
            locationIcon.widthAnchor.constraint(equalToConstant: 24),
            locationIcon.heightAnchor.constraint(equalToConstant: 24),
            
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 10),
            locationLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            
            temperatureLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 20),
            temperatureLabel.topAnchor.constraint(equalTo: locationIcon.bottomAnchor, constant: 20),
            
            maxTempLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 20),
            maxTempLabel.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: -40),

            rainChanceLabel.leadingAnchor.constraint(equalTo: maxTempLabel.trailingAnchor, constant: 10),
            rainChanceLabel.centerYAnchor.constraint(equalTo: maxTempLabel.centerYAnchor),

            weatherIcon.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -20),
            weatherIcon.centerYAnchor.constraint(equalTo: detailsView.centerYAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 100),
            weatherIcon.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func addRegionButtons() {
        for region in regions {
            let button = UIButton()
            button.setTitle(region.0, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1.0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.layer.cornerRadius = 10 // 둥근 모서리
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.2
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowRadius = 5
            
            button.addTarget(self, action: #selector(regionButtonTapped(_:)), for: .touchUpInside)
            
            let x = CGFloat(region.1) / 1030 * mapView.frame.size.width
            let y = CGFloat(region.2) / 1352 * mapView.frame.size.height
            let width = CGFloat(region.3) / 1030 * mapView.frame.size.width
            let height = CGFloat(region.4) / 1352 * mapView.frame.size.height
            button.frame = CGRect(x: x, y: y, width: width, height: height)
            mapView.addSubview(button)
        }
    }
    
    @objc func regionButtonTapped(_ sender: UIButton) {
        guard let regionName = sender.title(for: .normal) else { return }
        selectedRegionName = regionName
        print("\(regionName) 버튼이 눌렸습니다.")
        weatherFetcher.fetchWeather(for: regionName)
    }
    
    func didUpdateWeather(_ weatherData: WeatherData) {
        DispatchQueue.main.async {
            self.locationLabel.text = self.selectedRegionName
            self.temperatureLabel.text = "\(Int(weatherData.main.temp))°C"
            self.maxTempLabel.text = "최고 \(Int(weatherData.main.temp_max))°"
            self.rainChanceLabel.text = "☂️ \(weatherData.main.humidity)%"
            
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
