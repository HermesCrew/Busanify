//
//  WeatherViewController.swift
//  Busanify
//
//  Created by 장예진 on 7/8/24.
//

// TODO: 뷰 레퍼런스 탐색
// TODO:  좌표 별로 버튼 탭 하면 구별로 업데이트 가능하도록 하기
// TODO: 주 별 날씨 넣기
// TODO: 모달로  상세뷰 뜨게하기 ?

import UIKit
import WeatherKit
import CoreLocation
import Combine

class WeatherViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    private let regionPickerView = UIPickerView()
    
    private let regions: [Region] = [
           Region(name: "강서구", latitude: 35.20916389, longitude: 128.9829083),
           Region(name: "금정구", latitude: 35.24007778, longitude: 129.0943194),
           Region(name: "남구", latitude: 35.13340833, longitude: 129.0865),
           Region(name: "동구", latitude: 35.13589444, longitude: 129.059175),
           Region(name: "동래구", latitude: 35.20187222, longitude: 129.0858556),
           Region(name: "부산진구", latitude: 35.15995278, longitude: 129.0553194),
           Region(name: "북구", latitude: 35.19418056, longitude: 128.992475),
           Region(name: "사상구", latitude: 35.14946667, longitude: 128.9933333),
           Region(name: "사하구", latitude: 35.10142778, longitude: 128.9770417),
           Region(name: "서구", latitude: 35.09483611, longitude: 129.0263778),
           Region(name: "수영구", latitude: 35.14246667, longitude: 129.115375),
           Region(name: "연제구", latitude: 35.17318611, longitude: 129.082075),
           Region(name: "영도구", latitude: 35.08811667, longitude: 129.0701861),
           Region(name: "중구", latitude: 35.10321667, longitude: 129.0345083),
           Region(name: "해운대구", latitude: 35.16001944, longitude: 129.1658083),
           Region(name: "기장군", latitude: 35.24477541, longitude: 129.2222873)
       ]
    
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
        regionPickerView.delegate = self
        regionPickerView.dataSource = self
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
        
        regionPickerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(regionPickerView)
        
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
            
            regionPickerView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10),
            regionPickerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            weatherImageView.topAnchor.constraint(equalTo: regionPickerView.bottomAnchor, constant: 20),
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
                    self?.locationLabel.text = "Failed to get location"
                    self?.weatherLabel.text = "Failed to get weather: \(error)"
                    self?.maxMinTempLabel.text = ""
                    self?.weatherImageView.image = UIImage(systemName: "xmark.octagon")
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateWeather() {
        guard let weather = viewModel.currentWeather else { return }
        
        let temperature = Int(weather.currentWeather.temperature.value)
        weatherLabel.text = "\(temperature)°"
        conditionLabel.text = weather.currentWeather.condition.rawValue
        maxMinTempLabel.text = "H: \(Int(weather.dailyForecast.first?.highTemperature.value ?? 0))° L: \(Int(weather.dailyForecast.first?.lowTemperature.value ?? 0))°"
        
        if let weatherImage = WeatherIcon.getWeatherIcon(for: weather.currentWeather) {
            weatherImageView.image = weatherImage
        } else {
            weatherImageView.image = UIImage(systemName: "questionmark.circle")
        }
        
        hourlyForecastCollectionView.reloadData()
        dailyForecastTableView.reloadData()
    }
    
    // UIPickerView DataSource and Delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regions[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRegion = regions[row]
        let location = CLLocation(latitude: selectedRegion.latitude, longitude: selectedRegion.longitude)
        viewModel.fetchWeather(for: location)
    }
    
    // UICollectionView DataSource and Delegate methods
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
    
    // UICollectionViewDelegateFlowLayout method
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 6 // 한 줄에 표시할 셀의 개수에 맞게 조정
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
    // UITableView DataSource and Delegate methods
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
