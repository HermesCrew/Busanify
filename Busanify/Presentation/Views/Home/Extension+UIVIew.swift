//
//  CustomViews.swift
//  Busanify
//
//  Created by MadCow on 2024/7/3.
//

// -MARK: weatherFetcher를 사용하여 날씨 정보 업데이트 가능하도록 weathercontainer수정
// -MARK: weather버튼 추가 , 화면 넘어갈수있도록 delegate 추가

import UIKit
import Combine
import WeatherKit

protocol WeatherContainerDelegate: AnyObject {
    func didTapWeatherButton()
}

class WeatherContainer: UIView {
    weak var delegate: WeatherContainerDelegate?
    let icon = UIImageView()
    let label = UILabel()
    let locationLabel = UILabel()
    let button = UIButton(type: .system)
    
    private var viewModel: WeatherViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureContainer()
        configureSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        viewModel.$currentWeather
            .sink { [weak self] weather in
                if let currentWeather = weather?.currentWeather {
                    let temperature = currentWeather.temperature.value
                    let icon = WeatherIcon.getWeatherIcon(for: currentWeather)
                    self?.updateWeather(temperature: temperature, weatherImage: icon!)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$selectedRegion
            .sink { [weak self] region in
                let resolvedRegion = region ?? "부산광역시 서면"
                self?.updateLocation(resolvedRegion)
            }
            .store(in: &cancellables)

    }
    
    func updateWeather(temperature: Double, weatherImage: UIImage) {
        DispatchQueue.main.async {
            self.label.text = "\(Int(temperature))°C"
            self.icon.image = weatherImage
        }
    }
    
    private func updateLocation(_ location: String) {
        DispatchQueue.main.async {
            self.locationLabel.text = location
        }
    }
    
    private func configureContainer() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
    }
    
    private func configureSubviews() {
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .orange
        addSubview(icon)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13)
        addSubview(label)
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.textColor = .gray
        locationLabel.isHidden = true // 지역 이름 숨김 처리
        locationLabel.font = UIFont.systemFont(ofSize: 11)
        addSubview(locationLabel)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(button)
        
        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            icon.heightAnchor.constraint(equalToConstant: 24),
            icon.widthAnchor.constraint(equalToConstant: 24),
            
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: -10),
            
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    @objc private func buttonTapped() {
        delegate?.didTapWeatherButton()
    }
}

class CategoryButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton()
    }
    
    convenience init(
        text: String,
        textSize: CGFloat = 14,
        image: UIImage?,
        color: UIColor
    ) {
        self.init()
        
        self.setTitle(text, for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.setImage(image, for: .normal)
        self.tintColor = color
        self.backgroundColor = .white
        self.titleLabel?.font = UIFont.systemFont(ofSize: textSize, weight: .bold)
        self.layer.cornerRadius = 20
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 0.7
//        self.layer.shadowOffset = CGSize(width: 3, height: 3)
//        self.layer.shadowRadius = 3

        if let title = self.title(for: .normal), let font = self.titleLabel?.font {
            let titleSize = (title as NSString).size(withAttributes: [NSAttributedString.Key.font: font])

            self.widthAnchor.constraint(equalToConstant: titleSize.width + 50).isActive = true
            self.heightAnchor.constraint(equalToConstant: titleSize.height + 20).isActive = true
        }
    }
    
    func configureButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

class SearchTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTextField()
    }
    
    func configureTextField() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.placeholder = NSLocalizedString("search", comment: "")
        self.borderStyle = .roundedRect
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.returnKeyType = .search
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.textColor = .black
        self.setLeftPaddingPoints(30)
    }
    
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = emptyView
        self.leftViewMode = .always
    }
}

class CustomCompass: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton()
    }
    
    func configureButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        
        if let triangleImage = UIImage(systemName: "triangle.fill") {
            let triangleImageView = UIImageView(image: triangleImage)
            triangleImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
            triangleImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
            triangleImageView.tintColor = .red
            stackView.addArrangedSubview(triangleImageView)
        }
        
        let label = UILabel()
        label.text = "N"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        stackView.addArrangedSubview(label)
        
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

class CustomLocationButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton()
    }
    
    func configureButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = true
        
        let triangleImageView = UIImageView(image: UIImage(systemName: "dot.scope"))
        triangleImageView.translatesAutoresizingMaskIntoConstraints = false
        triangleImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        triangleImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        self.addSubview(triangleImageView)
        
        NSLayoutConstraint.activate([
            triangleImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            triangleImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

class RatingStackView: UIStackView {
    var onRatingChanged: ((Double) -> Void)?
    
    private(set) var rating: CGFloat = 0 {
        didSet {
            updateStarImages()
        }
    }
    
    private let starCount = 5
    private let starSize: CGFloat = 30
    
    init() {
        super.init(frame: .zero)
        setupStackView()
        setupStars()
        setupGesture()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
        setupStars()
        setupGesture()
    }
    
    private func setupStackView() {
        axis = .horizontal
        spacing = 10
        distribution = .fillEqually
        isUserInteractionEnabled = true
    }
    
    private func setupStars() {
        for i in 0..<starCount {
            let starImageView = UIImageView(image: .init(systemName: "star"))
            starImageView.tintColor = .systemYellow
            starImageView.contentMode = .scaleAspectFit
            starImageView.tag = i
            
            addArrangedSubview(starImageView)
            
            starImageView.widthAnchor.constraint(equalToConstant: starSize).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: starSize).isActive = true
        }
    }
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began, .changed:
            updateRating(at: location)
        default:
            break
        }
    }
    
    private func updateRating(at location: CGPoint) {
        let starWidth = starSize + spacing
        var newRating = location.x / starWidth
        newRating = max(0, min(CGFloat(starCount), newRating))
        
        rating = round(newRating * 2) / 2
        onRatingChanged?(rating)
    }
    
    private func updateStarImages() {
        for i in 0..<starCount {
            if let starImageView = arrangedSubviews[i] as? UIImageView {
                if CGFloat(i) + 1 <= rating {
                    starImageView.image = .init(systemName: "star.fill")
                } else if CGFloat(i) + 0.5 == rating {
                    starImageView.image = .init(systemName: "star.leadinghalf.filled")
                } else {
                    starImageView.image = .init(systemName: "star")
                }
            }
        }
    }
    
    func getStarCounts() -> Double {
        var fullStars: Double = 0
        var halfStars: Double = 0

        for arrangedSubview in arrangedSubviews {
            if let imageView = arrangedSubview as? UIImageView,
               let image = imageView.image {
                if image.isEqual(UIImage(systemName: "star.fill")) {
                    fullStars += 1
                } else if image.isEqual(UIImage(systemName: "star.leadinghalf.filled")) {
                    halfStars += 0.5
                }
            }
        }

        return fullStars + halfStars
    }
    
    func setStarCount(_ count: Double) {
        rating = count
        updateStarImages()
    }
}
