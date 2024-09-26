//
//  PlaceInfoTableViewCell.swift
//  Busanify
//
//  Created by 이인호 on 7/17/24.
//

import UIKit

final class PlaceInfoTableViewCell: UITableViewCell {
    static let identifier = "placeInfo"
    
    private let iconImageView = UIImageView()
    private let infoLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .byTruncatingTail
        infoLabel.showsExpansionTextWhenTruncated = true
        infoLabel.font = UIFont.systemFont(ofSize: 15)

        contentView.addSubview(iconImageView)
        contentView.addSubview(infoLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            infoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            infoLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with placeInfo: (String, String)) {
        infoLabel.text = placeInfo.0
        iconImageView.image = UIImage(systemName: placeInfo.1)
    }
}
