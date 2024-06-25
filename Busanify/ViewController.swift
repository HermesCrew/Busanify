//
//  ViewController.swift
//  Busanify
//
//  Created by 이인호 on 6/16/24.
//


// MARK: WeatherView layout Test를 위한 수정 (예진)

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let weatherButton = UIButton(type: .system)
        weatherButton.setTitle("Show Weather", for: .normal)
        weatherButton.addTarget(self, action: #selector(showWeather), for: .touchUpInside)
        weatherButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(weatherButton)
        
        NSLayoutConstraint.activate([
            weatherButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            weatherButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    @objc func showWeather() {
        print("Show Weather button pressed")
        let weatherVC = WeatherViewController()
        guard let navigationController = self.navigationController else {
            print("NavigationController is nil")
            return
        }
        navigationController.pushViewController(weatherVC, animated: true)
    }
}

}

