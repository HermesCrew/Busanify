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
    let reviewCountLabel = UILabel()
    var bookmarkToggleHandler: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
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
        
        ratingLabel.font = UIFont.systemFont(ofSize: 15)
        ratingLabel.textColor = .systemBlue
        contentView.addSubview(ratingLabel)
        
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .fillEqually
        ratingStackView.spacing = 2
        contentView.addSubview(ratingStackView)
        
        reviewCountLabel.font = UIFont.systemFont(ofSize: 14)
        reviewCountLabel.textColor = .darkGray
        contentView.addSubview(reviewCountLabel)
        
        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        contentView.addSubview(bookmarkButton)
        
        [placeImageView, titleLabel, addressLabel, openTimeLabel, ratingLabel, bookmarkButton, ratingStackView, reviewCountLabel].forEach {
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
            ratingLabel.centerYAnchor.constraint(equalTo: ratingStackView.centerYAnchor),
            ratingLabel.widthAnchor.constraint(equalToConstant: 22),
            
            ratingStackView.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 3),
            ratingStackView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            
            reviewCountLabel.leadingAnchor.constraint(equalTo: ratingStackView.trailingAnchor, constant: 4),
            reviewCountLabel.topAnchor.constraint(equalTo: ratingStackView.topAnchor),
            reviewCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: ratingStackView.bottomAnchor),
            
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
        bookmarkToggleHandler?(!bookmarkButton.isSelected)
    }
    
    func configure(with viewModel: PlaceCellViewModel) {
        titleLabel.text = viewModel.title
        addressLabel.text = viewModel.address
        ratingLabel.text = String(format: "%.1f", viewModel.avgRating)
        //reviewCountLabel.text = viewModel.reviewCount
        
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
    
    private func setupStarRating(rating: Double) {
        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            
            let fillRatio = min(max(rating - Double(i), 0), 1)
            
            let filledStarImage = drawPartialStar(fillRatio: CGFloat(fillRatio))
            starImageView.image = filledStarImage
            
            ratingStackView.addArrangedSubview(starImageView)
            
            starImageView.widthAnchor.constraint(equalTo: starImageView.heightAnchor).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        }
    }
    
    private func drawPartialStar(fillRatio: CGFloat) -> UIImage? {
        let size = CGSize(width: 24, height: 22)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            let emptyStarImage = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate)
            UIColor.systemYellow.setFill()
            emptyStarImage?.draw(in: rect)
            
            let filledStarImage = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
            context.cgContext.saveGState()
            context.cgContext.clip(to: CGRect(x: 0, y: 0, width: size.width * fillRatio, height: size.height))
            UIColor.systemYellow.setFill()
            filledStarImage?.draw(in: rect)
            context.cgContext.restoreGState()
        }
    }
}
