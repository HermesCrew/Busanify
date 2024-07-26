//
//  WeatherViewController.swift
//  Busanify
//
//  Created by 장예진 on 7/8/24.
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
    private let cityLabel = UILabel()
    private let districtLabel = UILabel()
    private let weatherLabel = UILabel()
    private let conditionLabel = UILabel()
    private let maxMinTempLabel = UILabel()
    private let weatherImageView = UIImageView()
    private let hourlyForecastCollectionView: UICollectionView
    private let dailyForecastTableView = UITableView()
    private let locationSymbolButton = UIButton()
    
    private var regions: [Region] = Regions.all
    
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
        setupBindings()
        
        hourlyForecastCollectionView.delegate = self
        hourlyForecastCollectionView.dataSource = self
        dailyForecastTableView.delegate = self
        dailyForecastTableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        self.title = "날씨"
        self.navigationController?.navigationBar.barTintColor = .white
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle("back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        
        let menuButton = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(menuButtonTapped))
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func menuButtonTapped() {
        let alertController = UIAlertController(title: "지역 선택", message: nil, preferredStyle: .actionSheet)
        
        for region in regions {
            let action = UIAlertAction(title: region.name, style: .default) { _ in
                self.selectRegion(region)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        
        present(alertController, animated: true, completion: nil)
    }

    private func selectRegion(_ region: Region) {
        let location = CLLocation(latitude: region.latitude, longitude: region.longitude)
        viewModel.fetchWeather(for: location, isCurrentLocation: false)
        viewModel.selectedRegion = region.name
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        cityLabel.textAlignment = .center
        cityLabel.text = "부산광역시"
        contentView.addSubview(cityLabel)

        districtLabel.translatesAutoresizingMaskIntoConstraints = false
        districtLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        districtLabel.textAlignment = .center
        districtLabel.text = "Loading..."
        contentView.addSubview(districtLabel)
        
        locationSymbolButton.translatesAutoresizingMaskIntoConstraints = false
        locationSymbolButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        locationSymbolButton.tintColor = .gray
        locationSymbolButton.isHidden = true
        locationSymbolButton.addTarget(self, action: #selector(locationSymbolTapped), for: .touchUpInside)
        contentView.addSubview(locationSymbolButton)
        
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherLabel.textAlignment = .center
        weatherLabel.font = UIFont.systemFont(ofSize: 80, weight: .light)
        contentView.addSubview(weatherLabel)
        
        conditionLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionLabel.textAlignment = .center
        contentView.addSubview(conditionLabel)
        
        maxMinTempLabel.translatesAutoresizingMaskIntoConstraints = false
        maxMinTempLabel.textAlignment = .center
        contentView.addSubview(maxMinTempLabel)
        
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        weatherImageView.contentMode = .scaleAspectFit
        contentView.addSubview(weatherImageView)
        
        hourlyForecastCollectionView.translatesAutoresizingMaskIntoConstraints = false
        hourlyForecastCollectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: "HourlyForecastCell")
        hourlyForecastCollectionView.showsHorizontalScrollIndicator = false
        contentView.addSubview(hourlyForecastCollectionView)
        
        dailyForecastTableView.translatesAutoresizingMaskIntoConstraints = false
        dailyForecastTableView.register(DailyForecastCell.self, forCellReuseIdentifier: "DailyForecastCell")
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
            
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            cityLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            districtLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 5),
            districtLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            locationSymbolButton.centerYAnchor.constraint(equalTo: districtLabel.centerYAnchor),
            locationSymbolButton.trailingAnchor.constraint(equalTo: districtLabel.leadingAnchor, constant: -5),
            locationSymbolButton.widthAnchor.constraint(equalToConstant: 20),
            locationSymbolButton.heightAnchor.constraint(equalToConstant: 20),
            
            weatherImageView.topAnchor.constraint(equalTo: districtLabel.bottomAnchor, constant: 20),
            weatherImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weatherImageView.heightAnchor.constraint(equalToConstant: 100),
            weatherImageView.widthAnchor.constraint(equalToConstant: 100),
            
            weatherLabel.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor, constant: 20),
            weatherLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            conditionLabel.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 10),
            conditionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            maxMinTempLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 10),
            maxMinTempLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            hourlyForecastCollectionView.topAnchor.constraint(equalTo: maxMinTempLabel.bottomAnchor, constant: 20),
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
                self?.locationSymbolButton.isHidden = !isCurrentLocation
            }
            .store(in: &cancellables)
    }
    
    @objc private func locationSymbolTapped() {
        viewModel.updateToCurrentLocation()
    }
    
    private func updateWeather() {
        guard let weather = viewModel.currentWeather else { return }
        
        let temperature = Int(weather.currentWeather.temperature.value)
        weatherLabel.text = "\(temperature)°"
        maxMinTempLabel.text = "최고: \(Int(weather.dailyForecast.first?.highTemperature.value ?? 0))° 최저: \(Int(weather.dailyForecast.first?.lowTemperature.value ?? 0))°"
        
        if let weatherImage = WeatherIcon.getWeatherIcon(for: weather.currentWeather) {
            weatherImageView.image = weatherImage
        } else {
            weatherImageView.image = UIImage(systemName: "questionmark.circle")
        }
        
        hourlyForecastCollectionView.reloadData()
        dailyForecastTableView.reloadData()
    }
    
    private func showError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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
        
        cell.configure(with: hourlyForecast, isNow: indexPath.item == 0)
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
