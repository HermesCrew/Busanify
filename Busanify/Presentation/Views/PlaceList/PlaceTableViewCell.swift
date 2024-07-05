//
//  PlaceTableViewCell.swift
//  Busanify
//
//  Created by seokyung on 7/5/24.
//

import Foundation
import UIKit

class PlaceTableViewCell: UITableViewCell {
    let placeImageView = UIImageView()
    let titleLabel = UILabel()
    let addressLabel = UILabel()
    let openTimeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        placeImageView.layer.cornerRadius = 8
        contentView.addSubview(placeImageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = .darkGray
        addressLabel.numberOfLines = 1
        contentView.addSubview(addressLabel)
        
        openTimeLabel.font = UIFont.systemFont(ofSize: 14)
        openTimeLabel.textColor = .gray
        openTimeLabel.numberOfLines = 0
        contentView.addSubview(openTimeLabel)
        
        [placeImageView, titleLabel, addressLabel, openTimeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            placeImageView.widthAnchor.constraint(equalToConstant: 110),
            placeImageView.heightAnchor.constraint(equalToConstant: 110),
            
            titleLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            addressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            addressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        
            openTimeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            openTimeLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            openTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            openTimeLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            
            DispatchQueue.main.async {
                self.placeImageView.image = image
            }
        }.resume()
    }
    
    func configure(with viewModel: PlaceCellViewModel) {
        titleLabel.text = viewModel.title
        addressLabel.text = viewModel.address
        openTimeLabel.text = viewModel.openTime
        
        placeImageView.image = nil
        if let imageURL = viewModel.imageURL {
            loadImage(from: imageURL)
        } else {
            placeImageView.image = UIImage(named: "placeholder")
        }
    }
}
