//
//  SettingTableViewCell.swift
//  Busanify
//
//  Created by 이인호 on 9/11/24.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    static let identifier = "setting"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        
        return imageView
    }()
    
    private let cellLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(cellLabel)
        selectionStyle = .none
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            cellLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            cellLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        ])
    }
    
    func configure(with settingInfo: (String, String)) {
        cellLabel.text = settingInfo.0
        iconImageView.image = UIImage(systemName: settingInfo.1)
    }
}

