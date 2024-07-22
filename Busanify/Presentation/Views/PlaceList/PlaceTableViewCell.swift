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
    let ratingLabel = UILabel()
    let bookmarkButton = UIButton(type: .custom)
    let ratingStackView = UIStackView()
    var bookmarkToggleHandler: ((Bool) -> Void)?
    
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
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = .darkGray
        addressLabel.numberOfLines = 1
        contentView.addSubview(addressLabel)
        
        openTimeLabel.font = UIFont.systemFont(ofSize: 14)
        openTimeLabel.textColor = .gray
        openTimeLabel.numberOfLines = 0
        contentView.addSubview(openTimeLabel)
        
        ratingLabel.font = UIFont.systemFont(ofSize: 14)
        ratingLabel.textColor = .systemBlue
        contentView.addSubview(ratingLabel)
        
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .fillEqually
        ratingStackView.spacing = 2
        contentView.addSubview(ratingStackView)
        
        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        contentView.addSubview(bookmarkButton)
        
        [placeImageView, titleLabel, addressLabel, openTimeLabel, ratingLabel, bookmarkButton, ratingStackView].forEach {
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
            
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 2),
            ratingLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            ratingLabel.widthAnchor.constraint(equalToConstant: 8),
            
            ratingStackView.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 8),
            ratingStackView.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            ratingStackView.widthAnchor.constraint(equalToConstant: 100),
            ratingStackView.heightAnchor.constraint(equalToConstant: 20),
            
            openTimeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            openTimeLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            openTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            openTimeLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            bookmarkButton.topAnchor.constraint(equalTo: placeImageView.topAnchor, constant: 5),
            bookmarkButton.leadingAnchor.constraint(equalTo: placeImageView.leadingAnchor, constant: 5),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30)
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
    
    @objc private func bookmarkTapped() {
        print("Bookmark button tapped, current state: \(bookmarkButton.isSelected)")
            bookmarkToggleHandler?(!bookmarkButton.isSelected)
        }
    
    func configure(with viewModel: PlaceCellViewModel) {
        titleLabel.text = viewModel.title
        addressLabel.text = viewModel.address
        
        ratingLabel.text = "\(viewModel.avgRating)"
        if let openTime = viewModel.openTime {
            openTimeLabel.text = openTime
            openTimeLabel.isHidden = false
        } else {
            openTimeLabel.isHidden = true
        }
        
        placeImageView.image = nil
        if let imageURL = viewModel.imageURL {
            loadImage(from: imageURL)
        } else {
            placeImageView.image = UIImage(named: "placeholder")
        }
        
        bookmarkButton.isSelected = viewModel.isBookmarked
        setupStarRating(rating: viewModel.avgRating)
    }
    
    private func setupStarRating(rating: Int) {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            if i <= rating {
                starImageView.image = UIImage(systemName: "star.fill")
            } else {
                starImageView.image = UIImage(systemName: "star")
            }
            starImageView.tintColor = .systemYellow
            ratingStackView.addArrangedSubview(starImageView)
        }
    }
}