//
//  DailyForecastCell.swift
//  Busanify
//
//  Created by 장예진 on 7/22/24.
//

import UIKit
import WeatherKit

class DailyForecastCell: UITableViewCell {
    private let dayLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let iconImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(iconImageView)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),

            temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            temperatureLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with forecast: DayWeather) {
        let day = Calendar.current.component(.day, from: forecast.date)
        dayLabel.text = "Day \(day)"
        temperatureLabel.text = "\(Int(forecast.highTemperature.value))° / \(Int(forecast.lowTemperature.value))°"
        iconImageView.image = UIImage(systemName: "cloud.sun.fill") // Example icon
    }
}
