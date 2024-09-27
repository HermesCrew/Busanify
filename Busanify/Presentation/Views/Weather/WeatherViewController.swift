//
//  WeatherViewController.swift
//  Busanify
//
//  Created by 장예진 on 7/26/24.
//

import UIKit
import WeatherKit
import CoreLocation
import Combine
import Foundation

class WeatherViewController: UIViewController {
    
    private var viewModel = WeatherViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let districtLabel = UILabel()
    private let currentWeatherStackView = UIStackView()
    private let temperatureLabel = UILabel()
    private let maxMinTempLabel = UILabel()
    private let weatherDescriptionLabel = UILabel()
    private let weatherImageView = UIImageView()
    private let hourlyForecastCollectionView: UICollectionView
    private let dailyForecastTableView = UITableView()
    private let locationSymbolButton = CustomLocationButton()
    private let precipitationIconImageView = UIImageView()
    private let precipitationProbabilityLabel = UILabel()
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        hourlyForecastCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        enableInteractivePopGesture()
        setupBindings()
        
        hourlyForecastCollectionView.delegate = self
        hourlyForecastCollectionView.dataSource = self
        dailyForecastTableView.delegate = self
        dailyForecastTableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        self.title = NSLocalizedString("weather", comment: "")
        self.navigationController?.navigationBar.barTintColor = .white
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        districtLabel.translatesAutoresizingMaskIntoConstraints = false
        districtLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        districtLabel.textAlignment = .left
        districtLabel.text = "Loading..."
        districtLabel.numberOfLines = 0 // 여러 줄 표시 허용
        contentView.addSubview(districtLabel)
        
        locationSymbolButton.addTarget(self, action: #selector(locationSymbolTapped), for: .touchUpInside)
        contentView.addSubview(locationSymbolButton)
        
        currentWeatherStackView.axis = .horizontal
        currentWeatherStackView.alignment = .center
        currentWeatherStackView.distribution = .fillEqually
        currentWeatherStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(currentWeatherStackView)

        weatherImageView.contentMode = .scaleAspectFit
        currentWeatherStackView.addArrangedSubview(weatherImageView)

        let tempStackView = UIStackView()
        tempStackView.axis = .vertical
        tempStackView.alignment = .center
        tempStackView.spacing = 10
        currentWeatherStackView.addArrangedSubview(tempStackView)

        temperatureLabel.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
        temperatureLabel.textColor = .systemBlue
        tempStackView.addArrangedSubview(temperatureLabel)

        maxMinTempLabel.font = UIFont.systemFont(ofSize: 16)
        tempStackView.addArrangedSubview(maxMinTempLabel)

        let precipitationStackView = UIStackView()
        precipitationStackView.axis = .horizontal
        precipitationStackView.alignment = .center
        precipitationStackView.spacing = 5

        precipitationIconImageView.contentMode = .scaleAspectFit
        precipitationIconImageView.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        precipitationStackView.addArrangedSubview(precipitationIconImageView)

        precipitationProbabilityLabel.font = UIFont.systemFont(ofSize: 16)
        precipitationProbabilityLabel.textColor = UIColor.systemPurple.withAlphaComponent(0.8)
        precipitationStackView.addArrangedSubview(precipitationProbabilityLabel)
        tempStackView.addArrangedSubview(precipitationStackView)

        hourlyForecastCollectionView.translatesAutoresizingMaskIntoConstraints = false
        hourlyForecastCollectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: "HourlyForecastCell")
        hourlyForecastCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(hourlyForecastCollectionView)
        
        dailyForecastTableView.translatesAutoresizingMaskIntoConstraints = false
        dailyForecastTableView.register(DailyForecastCell.self, forCellReuseIdentifier: "DailyForecastCell")
        
        dailyForecastTableView.allowsSelection = false

        contentView.addSubview(dailyForecastTableView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            districtLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            districtLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            locationSymbolButton.centerYAnchor.constraint(equalTo: districtLabel.centerYAnchor),
            locationSymbolButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            currentWeatherStackView.topAnchor.constraint(equalTo: districtLabel.bottomAnchor, constant: 25),
            currentWeatherStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currentWeatherStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            currentWeatherStackView.heightAnchor.constraint(equalToConstant: 150),

            weatherImageView.widthAnchor.constraint(equalToConstant: 100),
            weatherImageView.heightAnchor.constraint(equalToConstant: 100),
            
            hourlyForecastCollectionView.topAnchor.constraint(equalTo: currentWeatherStackView.bottomAnchor, constant: 40),
            hourlyForecastCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hourlyForecastCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            hourlyForecastCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            dailyForecastTableView.topAnchor.constraint(equalTo: hourlyForecastCollectionView.bottomAnchor, constant: 20),
            dailyForecastTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dailyForecastTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dailyForecastTableView.heightAnchor.constraint(equalToConstant: 400),
            dailyForecastTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }


    private func setupBindings() {
        viewModel.$currentWeather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateWeather()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedRegion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] region in
                self?.districtLabel.text = region
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isCurrentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isCurrentLocation in
                self?.locationSymbolButton.tintColor = isCurrentLocation ? .systemBlue : .systemGray
            }
            .store(in: &cancellables)
    }
    
    @objc private func locationSymbolTapped() {
        viewModel.updateToCurrentLocation()
    }
    
    private func updateWeather() {
        guard let weather = viewModel.currentWeather else { return }
        
        let temperature = Int(weather.currentWeather.temperature.value)
        temperatureLabel.text = "\(temperature)°C"
        
        let highTemp = Int(weather.dailyForecast.first?.highTemperature.value ?? 0)
        let lowTemp = Int(weather.dailyForecast.first?.lowTemperature.value ?? 0)
        maxMinTempLabel.text = "\(NSLocalizedString("Highest", comment: "")) \(highTemp)° / \(NSLocalizedString("Lowest", comment: "")) \(lowTemp)°"
        
        // 강수 확률 설정
        if let precipitationChance = weather.hourlyForecast.first?.precipitationChance {
            let probability = Int(precipitationChance * 100)
            precipitationProbabilityLabel.text = "\(probability)%"
            precipitationIconImageView.image = UIImage(systemName: "umbrella.fill")
        } else {
            precipitationProbabilityLabel.text = "N/A"
            precipitationIconImageView.image = nil
        }
        
        if let weatherImage = WeatherIcon.getWeatherIcon(for: weather.currentWeather) {
            weatherImageView.image = weatherImage
        } else {
            weatherImageView.image = UIImage(systemName: "questionmark.circle")
        }
        
        hourlyForecastCollectionView.reloadData()
        dailyForecastTableView.reloadData()
    }
    
    private func showError(_ error: String) {
        let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource and Delegate methods
extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sortedHourlyForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyForecastCell", for: indexPath) as! HourlyForecastCell
        let hourlyForecast = viewModel.sortedHourlyForecast[indexPath.item]
        
        let isNow = indexPath.item == 0 && Calendar.current.isDateInToday(hourlyForecast.date) && Calendar.current.component(.hour, from: hourlyForecast.date) == Calendar.current.component(.hour, from: Date())
        cell.configure(with: hourlyForecast, isNow: isNow)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 5 // 한 줄에 표시할 셀의 개수에 맞게 조정
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
}

// MARK: - UITableView DataSource and Delegate methods
extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentWeather?.dailyForecast.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailyForecastCell", for: indexPath) as! DailyForecastCell
        if let weather = viewModel.currentWeather {
            let dailyForecast = weather.dailyForecast[indexPath.row]
            cell.configure(with: dailyForecast)
        }
        return cell
    }
}
