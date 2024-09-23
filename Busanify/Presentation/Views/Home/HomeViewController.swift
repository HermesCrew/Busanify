//
//  HomeViewController.swift
//  Busanify
//
//  Created by MadCow on 2024/6/24.
//

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
//    let listView = SelectedPlaceListViewController()
//    let listView = PlaceListViewController()
    private var listContainerView: UIView!
    private var listViewController: PlaceListViewController!
    private var listViewHeightConstraint: NSLayoutConstraint!
    private let minimumListHeight: CGFloat = 140
    private let maximumListHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    var tempMovedLat: Double = 0
    var tempMovedLng: Double = 0
    var currentZoomLevel: Int = 15
    var currentRadius: Double {
        get {
            return 1000.0 + (15.0 - Double(currentZoomLevel)) * 300.0
        }
    }
    var tempPlaceType: PlaceType? = nil
    
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
    let viewModel = HomeViewModel()
    private var cancellable = Set<AnyCancellable>()
    private var minimumDetent = UISheetPresentationController.Detent.custom(resolver: { context in
        return 140
    })
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
//        mapContainer?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPresent)))
        
        //KMController 생성.
        mapController = KMController(viewContainer: mapContainer!)
        mapController?.proMotionSupport = true;
        mapController!.delegate = self
        
        // WeatherManager 설정 및 데이터 요청
        weatherManager.delegate = self
        weatherManager.startFetchingWeather()
        
        // WeatherContainer delegate 설정
        weatherContainer.delegate = self
        
        setSubscriber()
        configureUI()
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
        dismiss(animated: false)
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
                guard let self = self, let mapController = self.mapController, let view = mapController.getView("mapview") as? KakaoMap else { return }
                let manager = view.getLabelManager()
                manager.removeLabelLayer(layerID: "LocationLayer")
                if places.count > 0 {
                    self.createLabelLayer(layerID: "LocationLayer")
                    self.createPoiStyle(styleID: "LocationStyle", placeType: tempPlaceType)
                    let mapPoints = places.map { MapPoint(longitude: $0.lng, latitude: $0.lat) }
                    self.createPois(layerID: "LocationLayer", styleID: "LocationStyle", poiID: "", mapPoints: mapPoints, titles: places.map{ $0.title })
                }
            }
            .store(in: &cancellable)
    }
    
    func configureUI() {
        setupListView()
        setWeatherArea()
        setCategoryButtons()
        setCurrentLocationButton()
    }
    
    private func setupListView() {
        listContainerView = UIView()
        listContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listContainerView)
        
        listViewController = PlaceListViewController()
        addChild(listViewController)
        listContainerView.addSubview(listViewController.view)
        listViewController.didMove(toParent: self)
        
        listViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            listContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            listViewController.view.topAnchor.constraint(equalTo: listContainerView.topAnchor),
            listViewController.view.leadingAnchor.constraint(equalTo: listContainerView.leadingAnchor),
            listViewController.view.trailingAnchor.constraint(equalTo: listContainerView.trailingAnchor),
            listViewController.view.bottomAnchor.constraint(equalTo: listContainerView.bottomAnchor)
        ])
        
        listViewHeightConstraint = listContainerView.heightAnchor.constraint(equalToConstant: minimumListHeight)
        listViewHeightConstraint.isActive = true
        
        listContainerView.isHidden = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        listContainerView.addGestureRecognizer(panGesture)
    }
    
    func showListView() {
        listContainerView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.listViewHeightConstraint.constant = self.minimumListHeight
            self.view.layoutIfNeeded()
        }
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: listContainerView)
        let velocity = gesture.velocity(in: listContainerView)

        switch gesture.state {
        case .changed:
            let newHeight = listViewHeightConstraint.constant - translation.y
            listViewHeightConstraint.constant = min(max(newHeight, minimumListHeight), maximumListHeight)
            gesture.setTranslation(.zero, in: listContainerView)
        case .ended:
            let shouldExpand = velocity.y < 0 || listViewHeightConstraint.constant > (minimumListHeight + maximumListHeight) / 2
            let targetHeight = shouldExpand ? maximumListHeight : minimumListHeight
            
            UIView.animate(withDuration: 0.3) {
                self.listViewHeightConstraint.constant = targetHeight
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
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
            categoryScrollView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 5),
            categoryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 50),
            
            categoryContentView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryContentView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor),
            categoryContentView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor),
            categoryContentView.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor),
            categoryContentView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        var prevTrailingAnchor = categoryContentView.leadingAnchor
        PlaceType.allCases.enumerated().forEach{ (idx, btnInfo) in
            let btn = CategoryButton(text: btnInfo.placeInfo.0,
                                     image: UIImage(systemName: btnInfo.placeInfo.1),
                                     color: btnInfo.placeInfo.2)
            
            btn.addAction(UIAction{ [weak self] _ in
                guard let self = self else { return }
                // MARK: 지도에 핀을 찍기 위한거
                self.tempPlaceType = btnInfo
                self.viewModel.getLocationBy(typeId: btnInfo,
                                             lat: viewModel.currentLat,
                                             lng: viewModel.currentLong,
                                             radius: currentRadius)
                
                // MARK: ListViewController의 cell을 채우기 위해서
                self.listViewController.fetchPlaces(type: btnInfo, lat: viewModel.currentLat, lng: viewModel.currentLong, radius: currentRadius)
                self.presentListView(btnInfo: btnInfo)
            }, for: .touchUpInside)
            
            categoryContentView.addSubview(btn)
            
            NSLayoutConstraint.activate([
                btn.centerYAnchor.constraint(equalTo: categoryContentView.centerYAnchor),
                btn.leadingAnchor.constraint(equalTo: prevTrailingAnchor, constant: idx == 0 ? 0 : 10)
            ])
            
            if idx == PlaceType.allCases.count - 1 {
                btn.trailingAnchor.constraint(equalTo: categoryContentView.trailingAnchor).isActive = true
            }
            
            prevTrailingAnchor = btn.trailingAnchor
        }
    }
    
    func presentListView(btnInfo: PlaceType?) {
        if let presentedVC = presentedViewController as? PlaceListViewController {
            presentedVC.sheetPresentationController?.animateChanges {
                presentedVC.sheetPresentationController?.selectedDetentIdentifier = minimumDetent.identifier
            }
        } else {
            let listVC = PlaceListViewController()
            
            listVC.selectedPlaceType = btnInfo
            listVC.selectedLat = viewModel.currentLat
            listVC.selectedLng = viewModel.currentLong
            listVC.selectedRadius = currentRadius
            listVC.modalPresentationStyle = .pageSheet
            if let sheet = listVC.sheetPresentationController {
                sheet.detents = [minimumDetent, .large()]
                sheet.largestUndimmedDetentIdentifier = minimumDetent.identifier
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
            present(listVC, animated: true, completion: nil)
            self.listViewController = listVC
        }
    }
    
    func setCurrentLocationButton() {
        let currentButton = CustomLocationButton(type: .custom)
        view.addSubview(currentButton)
        
        NSLayoutConstraint.activate([
            currentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            currentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        currentButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let view = mapController?.getView("mapview") as? KakaoMap
            let currentLocation = self.viewModel.getCurrentLocation()
            currentZoomLevel = 15
            view?.animateCamera(cameraUpdate: .make(cameraPosition: .init(target: MapPoint(longitude: currentLocation.0, latitude: currentLocation.1),
                                                                          zoomLevel: 15,
                                                                          rotation: view!.rotationAngle,
                                                                          tilt: view!.tiltAngle)),
                                options: CameraAnimationOptions.init(autoElevation: true, consecutive: true, durationInMillis: 200))
        }, for: .touchUpInside)
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        // add for navigationController
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        _appear = false
        mapController?.pauseEngine()  //렌더링 중지.
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        mapController?.resetEngine()     //엔진 정지. 추가되었던 ViewBase들이 삭제된다.
    }
    
    func addViews() {
        // 임시로 부산이 아닐 때 서면역의 위,경도 설정
        let defaultPosition: MapPoint = MapPoint(longitude: viewModel.currentLong, latitude: viewModel.currentLat)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview",
                                                   viewInfoName: "map",
                                                   defaultPosition: defaultPosition,
                                                   defaultLevel: 15)
        currentZoomLevel = 15
        mapController?.addView(mapviewInfo)
    }
    
    func viewInit(viewName: String) {
        print("OK")
    }
    
    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        let view = mapController?.getView("mapview") as! KakaoMap
        
        let _ = view.addMapTappedEventHandler(target: view, handler: { map in
            return { [weak self] _ in
                guard let self = self else { return }
                dismissKeyboard()
            }
        })
        
        // 현재 위치 pin
        createLabelLayer(layerID: "PoiLayer")
        createPoiStyle(styleID: "My Location", currentLocation: true, placeType: nil)
        createPois(layerID: "PoiLayer",
                   styleID: "PerLevelStyle",
                   poiID: "mainPoi",
                   mapPoints: [MapPoint(longitude: viewModel.currentLong, latitude: viewModel.currentLat)],
                   titles: ["My Position"])
        
        let _ = view.addCameraWillMovedEventHandler(target: view) { map in
            return { [weak self] _ in
                guard let self = self else { return }
                if self.presentedViewController != nil {
                    self.listViewController.dismiss(animated: true)
                }
            }
        }
        
        // 카메라 이동 event
        let _ = view.addCameraStoppedEventHandler(target: view) { map in
            return { [weak self] _ in
                guard let self = self else { return }
                let mapPosition = map.getPosition(CGPoint(x: self.view.safeAreaLayoutGuide.layoutFrame.width / 2, y: self.view.safeAreaLayoutGuide.layoutFrame.height / 2))

                let movedLong = mapPosition.wgsCoord.longitude
                let movedLat = mapPosition.wgsCoord.latitude
                let view = mapController?.getView("mapview") as? KakaoMap
                // MARK: 카메라 이동하고 위, 경도 조정이 잘 안되는거같음
                currentZoomLevel = view?.zoomLevel ?? 15
                tempMovedLat = movedLat + 0.001
                tempMovedLng = movedLong
                viewModel.currentLong = movedLong
                viewModel.currentLat = movedLat + 0.001
            }
        }
        
        view.setCompassPosition(origin: GuiAlignment(vAlign: .bottom, hAlign: .left), position: CGPoint(x: 10.0, y: 100.0))
        view.showCompass()
        
        view.viewRect = mapContainer!.bounds    //뷰 add 도중에 resize 이벤트가 발생한 경우 이벤트를 받지 못했을 수 있음. 원하는 뷰 사이즈로 재조정.
        viewInit(viewName: viewName)
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
    
    @objc func dismissPresent() {
        if let presentedVC = presentedViewController as? PlaceListViewController {
            presentedVC.dismiss(animated: false)
        }
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
        if let text = textField.text {
            var btnInfo: PlaceType? = nil
            
            switch text {
            case "음식", "음식점":
                btnInfo = .restaurant
            case "쇼핑":
                btnInfo = .shopping
            case "숙박", "숙소", "잠":
                btnInfo = .accommodation
            case "관광", "관광지", "볼거":
                btnInfo = .touristAttraction
            default:
                // MARK: TODO - 입력한 텍스트로 검색기능 추가
                break
            }
            if let btnInfo = btnInfo {
                self.viewModel.getLocationBy(typeId: btnInfo,
                                             lat: viewModel.currentLat,
                                             lng: viewModel.currentLong,
                                             radius: currentRadius)
                
                self.listViewController.fetchPlaces(type: btnInfo, lat: viewModel.currentLat, lng: viewModel.currentLong, radius: currentRadius)
            } else {
                self.viewModel.getLocationsBy(keyword: text)
            }
            
            if let presentedVC = presentedViewController as? PlaceListViewController {
                presentedVC.dismiss(animated: false) {
                    self.presentListView(btnInfo: btnInfo)
                }
            } else {
                self.presentListView(btnInfo: btnInfo)
            }
        }
        return true
    }
}

extension HomeViewController: MoveToMapLocation {
    func moveTo(lat: CGFloat, lng: CGFloat) {
        let view = mapController?.getView("mapview") as? KakaoMap
        
        UIView.animate(withDuration: 0.3) {
            self.listViewHeightConstraint.constant = self.minimumListHeight
            self.view.layoutIfNeeded()
        }

        currentZoomLevel = 15
        view?.animateCamera(cameraUpdate: .make(cameraPosition: .init(target: MapPoint(longitude: lng, latitude: lat),
                                                                      zoomLevel: 15,
                                                                      rotation: view!.rotationAngle,
                                                                      tilt: view!.tiltAngle)),
                            options: CameraAnimationOptions.init(autoElevation: true, consecutive: true, durationInMillis: 200))
    }
}
