//
//  HourlyForecastCell.swift
//  Busanify
//
//  Created by 장예진 on 7/22/24.
//

import UIKit
import WeatherKit

class HourlyForecastCell: UICollectionViewCell {
    private let timeLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(iconImageView)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            
            temperatureLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 5),
            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            temperatureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with forecast: HourWeather) {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(now, equalTo: forecast.date, toGranularity: .hour) {
            timeLabel.text = "지금"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "a h시"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            timeLabel.text = dateFormatter.string(from: forecast.date)
        }
        
        temperatureLabel.text = "\(Int(forecast.temperature.value))°"
        iconImageView.image = WeatherIcon.getWeatherIcon(for: forecast)
    }
}
