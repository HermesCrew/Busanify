//
//  WeatherViewController.swift
//  Busanify
//
//  Created by 장예진 on 6/25/24.
//
import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var weatherData: WeatherData?

    let temperatureLabel = UILabel()
    let descriptionLabel = UILabel()
    let locationLabel = UILabel()
    let weatherIconImageView = UIImageView()
    let updateLocationButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Set up labels and image view
        temperatureLabel.font = UIFont.systemFont(ofSize: 32)
        temperatureLabel.textAlignment = .center
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 20)
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        locationLabel.font = UIFont.systemFont(ofSize: 20)
        locationLabel.textAlignment = .center
        locationLabel.translatesAutoresizingMaskIntoConstraints = false

        weatherIconImageView.contentMode = .scaleAspectFit
        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false

        updateLocationButton.setTitle("Update Location", for: .normal)
        updateLocationButton.addTarget(self, action: #selector(updateLocation), for: .touchUpInside)
        updateLocationButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(temperatureLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(locationLabel)
        view.addSubview(weatherIconImageView)
        view.addSubview(updateLocationButton)
        
        NSLayoutConstraint.activate([
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 20),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            locationLabel.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor, constant: -20),
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weatherIconImageView.bottomAnchor.constraint(equalTo: locationLabel.topAnchor, constant: -20),
            weatherIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 50),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            updateLocationButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            updateLocationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @objc func updateLocation() {
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            fetchWeatherData(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            locationManager.stopUpdatingLocation() // Stop updates to prevent repeated calls
        }
    }

    func fetchWeatherData(lat: Double, lon: Double) {
        let apiKey = "c1af2766a7485834f129e6f5755f1d5"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: decodedData)
                }
            } catch {
            }
        }
        task.resume()
    }
    
    func updateUI(with weatherData: WeatherData) {
        temperatureLabel.text = "\(weatherData.main.temp)°C"
        descriptionLabel.text = weatherData.weather.first?.description.capitalized
        locationLabel.text = weatherData.name

        if let icon = weatherData.weather.first?.icon {
            let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")!
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: iconURL) {
                    DispatchQueue.main.async {
                        self.weatherIconImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}
