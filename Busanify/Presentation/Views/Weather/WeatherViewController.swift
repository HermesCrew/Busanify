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
    private let weatherLabel = UILabel()
    private let locationLabel = UILabel()
    private let conditionLabel = UILabel()
    private let maxMinTempLabel = UILabel()
    private let weatherImageView = UIImageView()
    private let hourlyForecastCollectionView: UICollectionView
    private let dailyForecastTableView = UITableView()
    
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
        viewModel.fetchWeather(for: location)
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        locationLabel.textAlignment = .center
        locationLabel.text = "Loading..."
        contentView.addSubview(locationLabel)
        
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
        hourlyForecastCollectionView.showsVerticalScrollIndicator = false
        hourlyForecastCollectionView.isPagingEnabled = true
        hourlyForecastCollectionView.alwaysBounceVertical = true
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
            
            locationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            locationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            weatherImageView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
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
        
        viewModel.$locationName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locationName in
                self?.locationLabel.text = locationName
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
        return min(viewModel.currentWeather?.hourlyForecast.count ?? 0, 24) // 최대 24시간
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyForecastCell", for: indexPath) as! HourlyForecastCell
        if let weather = viewModel.currentWeather {
            let hourlyForecast = weather.hourlyForecast[indexPath.item]
            cell.configure(with: hourlyForecast)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 6 // 한 줄에 표시할 셀의 개수에 맞게 조정
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
