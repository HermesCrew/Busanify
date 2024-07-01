//
//  HomeViewController.swift
//  Busanify
//
//  Created by MadCow on 2024/6/24.
//

import UIKit
import KakaoMapsSDK

class HomeViewController: UIViewController, MapControllerDelegate {
    
    let weatherContainer: UIView = {
        let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        uv.backgroundColor = .white
        uv.layer.cornerRadius = 8
        uv.layer.shadowColor = UIColor.black.cgColor
        uv.layer.shadowOpacity = 0.1
        uv.layer.shadowOffset = CGSize(width: 0, height: 1)
        uv.layer.shadowRadius = 4
        
        return uv
    }()
    let weatherIcon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        let symbol = UIImage(systemName: "sun.max.fill")!
        icon.image = symbol
        
        icon.tintColor = .orange
        
        return icon
    }()
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "20°C"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13)
        
        return label
    }()
    lazy var searchTextField: UITextField = {
        let tf = UITextField()
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "검색하기"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.returnKeyType = .search
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textColor = .black
        tf.setLeftPaddingPoints(30)
        
        return tf
    }()
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
        
        return scroll
    }()
    let categoryContentView: UIView = {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .white
        
        return content
    }()
    
    private var cancellable = Set<AnyCancellable>()
    private var weatherContainerWidthConstraint: NSLayoutConstraint!
    private var searchTextFieldLeadingConstraint: NSLayoutConstraint!
    private var searchTextFieldLeadingConstraintExpanded: NSLayoutConstraint!
    private let latRange = 34.8799083...35.3959361
    private let longRange = 128.7384361...129.3728194
    private let viewModel = HomeViewModel()
    
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
        
        configureUI()
        setupTapGesture()
    }
    
    func configureUI() {
        setWeatherArea()
        setCategoryButtons()
    }
    
    func setWeatherArea() {
        view.addSubview(weatherContainer)
        view.addSubview(searchTextField)
        weatherContainer.addSubview(weatherIcon)
        weatherContainer.addSubview(temperatureLabel)
        
        weatherContainerWidthConstraint = weatherContainer.widthAnchor.constraint(equalToConstant: view.frame.width / 6.5)
        NSLayoutConstraint.activate([
            weatherContainer.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            weatherContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            weatherContainer.heightAnchor.constraint(equalToConstant: 40),
            weatherContainerWidthConstraint,
            
            weatherIcon.centerXAnchor.constraint(equalTo: weatherContainer.centerXAnchor),
            weatherIcon.centerYAnchor.constraint(equalTo: weatherContainer.centerYAnchor),
            weatherIcon.heightAnchor.constraint(equalToConstant: 24),
            weatherIcon.widthAnchor.constraint(equalToConstant: 24),
            
            temperatureLabel.leadingAnchor.constraint(equalTo: weatherIcon.trailingAnchor, constant: -15),
            temperatureLabel.centerYAnchor.constraint(equalTo: weatherContainer.centerYAnchor, constant: 8)
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
        
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: weatherContainer.bottomAnchor, constant: 20),
            categoryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 60),
            
            categoryContentView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryContentView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor),
            categoryContentView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor),
            categoryContentView.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor),
            categoryContentView.widthAnchor.constraint(equalToConstant: 1000)
        ])
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
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
        // 임시로 부산이 아닐 때 부산시청의 위,경도 설정
        var long = 129.0756
        var lat = 35.1796
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
                                                   defaultLevel: 14)
        
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
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 1)
        let _ = manager.addLabelLayer(option: layerOption)
        
        let layer = manager.getLabelLayer(layerID: "PoiLayer")
        let poiOption = PoiOptions(styleID: "PerLevelStyle")
        poiOption.rank = 0
        
        let poi1 = layer?.addPoi(option:poiOption, at: MapPoint(longitude: 129.0595, latitude: 35.1577))
        
        // MARK: TODO - UIImage 핀같은 이미지로 교체
        let badge = PoiBadge(badgeID: "noti", image: UIImage(systemName: "sun.max")!, offset: CGPoint(x: 0, y: 0), zOrder: 1)
        poi1?.addBadge(badge)
        poi1?.show()
        poi1?.showBadge(badgeID: "noti")
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

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = emptyView
        self.leftViewMode = .always
    }
}
