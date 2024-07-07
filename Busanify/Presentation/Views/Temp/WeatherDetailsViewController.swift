//
//  WeatherDetailsViewController.swift
//  Busanify
//
//  Created by 장예진 on 6/26/24.
//
//
//import UIKit
//
//class WeatherDetailsViewController: UIViewController {
//    var region: String = ""
//    let temperatureLabel = UILabel()
//    let descriptionLabel = UILabel()
//    let weatherIconImageView = UIImageView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        setupLabels()
//        setupWeatherIconImageView()
//        fetchWeatherData()
//    }
//
//    private func setupLabels() {
//        temperatureLabel.font = UIFont.systemFont(ofSize: 32)
//        temperatureLabel.textAlignment = .center
//        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        descriptionLabel.font = UIFont.systemFont(ofSize: 20)
//        descriptionLabel.textAlignment = .center
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(temperatureLabel)
//        view.addSubview(descriptionLabel)
//        
//        NSLayoutConstraint.activate([
//            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            temperatureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
//            
//            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 20)
//        ])
//    }
//
//    private func setupWeatherIconImageView() {
//        weatherIconImageView.contentMode = .scaleAspectFit
//        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(weatherIconImageView)
//
//        NSLayoutConstraint.activate([
//            weatherIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            weatherIconImageView.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor, constant: -20),
//            weatherIconImageView.widthAnchor.constraint(equalToConstant: 100),
//            weatherIconImageView.heightAnchor.constraint(equalToConstant: 100)
//        ])
//    }
//
//    private func fetchWeatherData() {
//        let apiKey = "your_api_key_here"  // Use your actual OpenWeatherMap API key
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(region)&appid=\(apiKey)&units=metric"
//        
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error fetching weather data: \(error)")
//                return
//            }
//            
//            guard let data = data,
//                  let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data) else {
//                print("Error decoding weather data")
//                return
//            }
//
//            DispatchQueue.main.async {
//                self.updateUI(with: weatherData)
//            }
//        }
//        task.resume()
//    }
//
//    private func updateUI(with weatherData: WeatherData) {
//        temperatureLabel.text = "\(weatherData.main.temp)°C"
//        descriptionLabel.text = weatherData.weather.first?.description.capitalized
//        updateWeatherIcon(iconCode: weatherData.weather.first?.icon ?? "")
//    }
//
//    private func updateWeatherIcon(iconCode: String) {
//        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")!
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: iconURL) {
//                DispatchQueue.main.async {
//                    self.weatherIconImageView.image = UIImage(data: data)
//                }
//            }
//        }
//    }
//}
