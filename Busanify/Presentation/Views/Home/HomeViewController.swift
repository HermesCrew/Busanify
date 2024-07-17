//
//  HomeViewController.swift
//  Busanify
//
//  Created by MadCow on 2024/6/24.
//

// MARK: didupdateWeather, didFailWithError method 를 추가하여 fetcher와 weathcontainer 연결 하였습니다. 감사합니다.

import UIKit
import KakaoMapsSDK
import Combine
import WeatherKit

class HomeViewController: UIViewController, MapControllerDelegate, WeatherContainerDelegate, WeatherManagerDelegate {
    
    // UIComponent
    private var weatherContainerWidthConstraint: NSLayoutConstraint!
    private var searchTextFieldLeadingConstraint: NSLayoutConstraint!
    private var searchTextFieldLeadingConstraintExpanded: NSLayoutConstraint!
    let weatherContainer = WeatherContainer()
    let searchTextField = SearchTextField()
    let searchIcon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: "magnifyingglass") // Use SF Symbol for search icon
        icon.tintColor = .gray
        
        return icon
    }()
    let categoryScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        
        return scroll
    }()
    let categoryContentView: UIView = {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .white
        
        return content
    }()
    
    // Data
    private var cancellable = Set<AnyCancellable>()
    private let latRange = 34.8799083...35.3959361
    private let longRange = 128.7384361...129.3728194
    private let viewModel = HomeViewModel()
    private var tempPinArr: [Poi?] = []
    private let weatherManager = WeatherManager()
    
    // WeatherViewController 연결.
    let weatherViewController = WeatherViewController()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        _observerAdded = false
        _auth = false
        _appear = false
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        _observerAdded = false
        _auth = false
        _appear = false
        super.init(coder: coder)
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        
        print("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        mapContainer = self.view as? KMViewContainer
        
        //KMController 생성.
        mapController = KMController(viewContainer: mapContainer!)
        mapController!.delegate = self
        
        // WeatherManager 설정 및 데이터 요청
        weatherManager.delegate = self
        weatherManager.startFetchingWeather()
        
        // WeatherContainer delegate 설정
        weatherContainer.delegate = self
        
        setSubscriber()
        configureUI()
        setupTapGesture()
    }
    
    // WeatherContainerDelegate 메서드 구현
    func didTapWeatherButton() {
        let weatherVC = WeatherViewController()
        
        if navigationController == nil {
            // 현재 ViewController를 NavigationController로 감싸주기!
            let navController = UINavigationController(rootViewController: self)
            
            // UIWindowScene을 사용하여 현재 창을 가져오기
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navController
                window.makeKeyAndVisible()
                
                // 새로운 ViewController push~
                navController.pushViewController(weatherVC, animated: true)
            } else {
                print("No window scene found")
            }
        } else {
            navigationController?.pushViewController(weatherVC, animated: true)
        }
    }

    // WeatherManagerDelegate 메서드 구현
    func didUpdateWeather(_ weather: Weather) {
        let temperature = weather.currentWeather.temperature.value
        let icon = WeatherIcon.getWeatherIcon(for: weather.currentWeather)
        weatherContainer.updateWeather(temperature: temperature, weatherImage: icon)
    }
    
    func didFailWithError(_ error: Error) {
        print("Failed to fetch weather: \(error)")
    }
    
    func setSubscriber() {
        viewModel.$searchedPlaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] places in
                guard let self = self else { return }
                self.tempPinArr.forEach{ pin in
                    pin?.hide()
                }
                self.tempPinArr = []
                if places.count > 0 {
                    let view = mapController?.getView("mapview") as! KakaoMap
                    let manager = view.getLabelManager()
                    manager.removeLabelLayer(layerID: "PoiLayer")
                    let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 0)
                    let _ = manager.addLabelLayer(option: layerOption)
                    let layer = manager.getLabelLayer(layerID: "PoiLayer")
                    let poiOption = PoiOptions(styleID: "PerLevelStyle")
                    
                    places.enumerated().forEach{ (i, place) in
                        poiOption.rank = 0
                        let poi = layer?.addPoi(option:poiOption, at: MapPoint(longitude: place.lng, latitude: place.lat))
                        self.tempPinArr.append(poi)
                        // MARK: TODO - UIImage 핀같은 이미지로 교체
                        let badge = PoiBadge(badgeID: "noti", image: UIImage(systemName: "sun.max")!.withTintColor(.orange), offset: CGPoint(x: 0, y: 0), zOrder: 0)
                        poi?.addBadge(badge)
                        poi?.show()
                        poi?.showBadge(badgeID: "noti")
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    func configureUI() {
        setWeatherArea()
        setCategoryButtons()
    }
    
    func setWeatherArea() {
        searchTextField.delegate = self
        view.addSubview(weatherContainer)
        view.addSubview(searchTextField)
        
        weatherContainerWidthConstraint = weatherContainer.widthAnchor.constraint(equalToConstant: view.frame.width / 6.5)
        NSLayoutConstraint.activate([
            weatherContainer.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            weatherContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            weatherContainer.heightAnchor.constraint(equalToConstant: 40),
            weatherContainerWidthConstraint
        ])
        
        view.addSubview(searchIcon)
        
        searchTextFieldLeadingConstraint = searchTextField.leadingAnchor.constraint(equalTo: weatherContainer.trailingAnchor, constant: 10)
        searchTextFieldLeadingConstraintExpanded = searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextFieldLeadingConstraint,
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        
        NSLayoutConstraint.activate([
            searchIcon.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            searchIcon.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor, constant: 8),
            searchIcon.heightAnchor.constraint(equalToConstant: 24),
            searchIcon.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func setCategoryButtons() {
        view.addSubview(categoryScrollView)
        categoryScrollView.addSubview(categoryContentView)
        categoryContentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: weatherContainer.bottomAnchor, constant: 5),
            categoryScrollView.leadingAnchor.constraint(equalTo: weatherContainer.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 50),
            
            categoryContentView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryContentView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor),
            categoryContentView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor),
            categoryContentView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        var prevTrailingAnchor = categoryContentView.leadingAnchor
        let btnArr = [("관광지", "flag.fill", UIColor.systemRed), ("음식점", "fork.knife", UIColor.systemOrange),
                      ("숙박", "bed.double.fill", UIColor.systemYellow), ("교통", "bus.fill", UIColor.systemCyan),
                      ("쇼핑", "handbag.fill", UIColor.systemPurple)]
        btnArr.enumerated().forEach{ (idx, btnInfo) in
            let btn = CategoryButton(text: btnInfo.0, image: UIImage(systemName: btnInfo.1), color: btnInfo.2)
            btn.addAction(UIAction{ [weak self] _ in
                guard let self = self else { return }
//                self.viewModel.getLocationsBy(keyword: btnInfo.0)
                self.viewModel.getLocationBy(lat: 35.1796, lng: 129.0756, radius: 3000)
            }, for: .touchUpInside)
            
            categoryContentView.addSubview(btn)
            
            NSLayoutConstraint.activate([
                btn.centerYAnchor.constraint(equalTo: categoryContentView.centerYAnchor),
                btn.leadingAnchor.constraint(equalTo: prevTrailingAnchor, constant: idx == 0 ? 0 : 10)
            ])
            
            if idx == btnArr.count - 1 {
                btn.trailingAnchor.constraint(equalTo: categoryContentView.trailingAnchor).isActive = true
            }
            
            prevTrailingAnchor = btn.trailingAnchor
        }
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        // MARK: navigationbar hidden 추가
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        addObservers()
        _appear = true
        if mapController?.isEnginePrepared == false {
            mapController?.prepareEngine()
        }
        
        if mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        _appear = false
        mapController?.pauseEngine()  //렌더링 중지.
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        mapController?.resetEngine()     //엔진 정지. 추가되었던 ViewBase들이 삭제된다.
    }
    
    // 인증 성공시 delegate 호출.
    func authenticationSucceeded() {
        // 일반적으로 내부적으로 인증과정 진행하여 성공한 경우 별도의 작업은 필요하지 않으나,
        // 네트워크 실패와 같은 이슈로 인증실패하여 인증을 재시도한 경우, 성공한 후 정지된 엔진을 다시 시작할 수 있다.
        if _auth == false {
            _auth = true
        }
        
        if _appear && mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    // 인증 실패시 호출.
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        _auth = false
        switch errorCode {
        case 400:
            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
            break;
        case 401:
            showToast(self.view, message: "지도 종료(API인증 키 오류)")
            break;
        case 403:
            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
            break;
        case 429:
            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
            break;
        case 499:
            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
            
            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.prepareEngine()
            }
            break;
        default:
            break;
        }
    }
    
    func addViews() {
        // 임시로 부산이 아닐 때 서면역의 위,경도 설정
        var long = 129.0595
        var lat = 35.1577
        if let currentLong = viewModel.currentLong, let currentLat = viewModel.currentLat {
            if longRange.contains(currentLong) && latRange.contains(currentLat) {
                long = currentLong
                lat = currentLat
            }
        }
        let defaultPosition: MapPoint = MapPoint(longitude: long, latitude: lat)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview",
                                                   viewInfoName: "map",
                                                   defaultPosition: defaultPosition,
                                                   defaultLevel: 13)
        
        mapController?.addView(mapviewInfo)
    }
    
    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        let view = mapController?.getView("mapview") as! KakaoMap
        
        // 지도에 나침반 표시
        view.setCompassPosition(origin: GuiAlignment(vAlign: .bottom, hAlign: .left), position: CGPoint(x: 10.0, y: 100.0))
        view.showCompass()
        view.setLanguage("en")
        view.viewRect = mapContainer!.bounds    //뷰 add 도중에 resize 이벤트가 발생한 경우 이벤트를 받지 못했을 수 있음. 원하는 뷰 사이즈로 재조정.
        
        // 현재 위치 핀 표시
        let manager = view.getLabelManager()
        let layerOption = LabelLayerOptions(layerID: "MainLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 0)
        let _ = manager.addLabelLayer(option: layerOption)
        
        let layer = manager.getLabelLayer(layerID: "MainLayer")
        let poiOption = PoiOptions(styleID: "PerLevelStyle")
        poiOption.rank = 0
        
        let poi = layer?.addPoi(option:poiOption, at: MapPoint(longitude: 129.0595, latitude: 35.1577))
        
        // MARK: TODO - UIImage 핀같은 이미지로 교체
        let pinImage = UIImage(systemName: "smallcircle.filled.circle")!.withTintColor(.systemRed)
        
        pinImage.withTintColor(.green, renderingMode: .alwaysTemplate)
        let badge = PoiBadge(badgeID: "noti", image: pinImage, offset: CGPoint(x: 0, y: 0), zOrder: 0)
        poi?.addBadge(badge)
        poi?.show()
        poi?.showBadge(badgeID: "noti")
    }
    
    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
    func containerDidResized(_ size: CGSize) {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)   //지도뷰의 크기를 리사이즈된 크기로 지정한다.
    }
       
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    
        _observerAdded = true
    }
     
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

        _observerAdded = false
    }

    @objc func willResignActive(){
        mapController?.pauseEngine()  //뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단.
    }

    @objc func didBecomeActive(){
        mapController?.activateEngine() //뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함.
    }
    
    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                                        toastLabel.alpha = 0.0
                                    },
                       completion: { (finished) in
                                        toastLabel.removeFromSuperview()
                                    })
    }
    
    var mapContainer: KMViewContainer?
    var mapController: KMController?
    var _observerAdded: Bool = false
    var _auth: Bool = false
    var _appear: Bool = false
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.weatherContainer.alpha = 0
            self.weatherContainerWidthConstraint.constant = 0
            self.searchTextFieldLeadingConstraint.isActive = false
            self.searchTextFieldLeadingConstraintExpanded.isActive = true
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.weatherContainer.isHidden = true
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.weatherContainer.isHidden = false
            self.weatherContainer.alpha = 1
            self.weatherContainerWidthConstraint.constant = 60
            self.searchTextFieldLeadingConstraintExpanded.isActive = false
            self.searchTextFieldLeadingConstraint.isActive = true
            self.view.layoutIfNeeded()
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
