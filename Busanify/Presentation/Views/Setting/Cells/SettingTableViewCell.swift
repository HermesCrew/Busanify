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
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        
        return label
    }()
    
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
        contentView.addSubview(label)
        selectionStyle = .none
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            cellLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            cellLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
        ])
    }
    
    func configure(with settingInfo: (String, String), labelText: String) {
        cellLabel.text = settingInfo.0
        iconImageView.image = UIImage(systemName: settingInfo.1)
        label.text = labelText
    }
}

