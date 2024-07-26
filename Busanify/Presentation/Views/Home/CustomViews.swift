//
//  CustomViews.swift
//  Busanify
//
//  Created by MadCow on 2024/7/3.
//

import UIKit

class WeatherContainer: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContainer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureContainer()
    }
    
    convenience init(
        temperature: Int,
        weatherImage: UIImage?
    ) {
        self.init()
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        let symbol = weatherImage
        icon.image = symbol
        icon.tintColor = .orange
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(temperature)°C"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13)
        
        self.addSubview(icon)
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            icon.heightAnchor.constraint(equalToConstant: 24),
            icon.widthAnchor.constraint(equalToConstant: 24),
            
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: -15),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 8)
        ])
    }
    
    func configureContainer() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 4
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
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.7
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 3

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
        self.placeholder = "검색하기"
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
