//
//  ViewController.swift
//  Busanify
//
//  Created by 이인호 on 6/16/24.
//

import UIKit

class ViewController: UIViewController, WeatherFetcherDelegate {
    func didFailWithError(_ error: any Error) {
        print("")
        
    }
    
    
    let weatherButton = UIButton(type: .system)
    let weatherFetcher = WeatherFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        weatherFetcher.delegate = self
        setupUI()
        weatherFetcher.startFetchingWeather()
    }
    
    func setupUI() {
        weatherButton.setTitle("Fetching weather...", for: .normal)
        weatherButton.translatesAutoresizingMaskIntoConstraints = false
        weatherButton.layer.cornerRadius = 10
        weatherButton.backgroundColor = .lightGray
        weatherButton.setTitleColor(.black, for: .normal)
        weatherButton.contentHorizontalAlignment = .left
        weatherButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        view.addSubview(weatherButton)
        
        NSLayoutConstraint.activate([
            weatherButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            weatherButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            weatherButton.widthAnchor.constraint(equalToConstant: 150),
            weatherButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        weatherButton.addTarget(self, action: #selector(showWeather), for: .touchUpInside)
    }
    
    func didUpdateWeather(_ weatherData: WeatherData) {
        let iconUrlString = "https://openweathermap.org/img/wn/\(weatherData.weather.first?.icon ?? "")@2x.png"
        guard let iconUrl = URL(string: iconUrlString) else {
            print("Invalid icon URL")
            return
        }
        
        let attributedTitle = NSMutableAttributedString()
        
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
                let attachment = NSTextAttachment()
                attachment.image = iconImage
                attachment.bounds = CGRect(x: 0, y: -5, width: 30, height: 30)
                attributedTitle.append(NSAttributedString(attachment: attachment))
                attributedTitle.append(NSAttributedString(string: " \(weatherData.name)\n\(weatherData.main.temp)°C"))
                
                self.weatherButton.setAttributedTitle(attributedTitle, for: .normal)
            }
        }
        
        task.resume()
    }
    
    @objc func showWeather() {
        let weatherVC = WeatherViewController()
        self.navigationController?.pushViewController(weatherVC, animated: true)
    }
}
