//
//  BookmarkGridCell.swift
//  Busanify
//
//  Created by seokyung on 7/20/24.
//

import Foundation
import UIKit
import Kingfisher

class BookmarkGridCell: UICollectionViewCell {
    let gridImageView = UIImageView()
    let titleLabel = UILabel()
    let ratingLabel = UILabel()
    let ratingStackView = UIStackView()
    let bookmarkButton = UIButton(type: .custom)
    var bookmarkToggleHandler: (() -> Void)?
    let reviewCountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        gridImageView.contentMode = .scaleAspectFill
        gridImageView.clipsToBounds = true
        gridImageView.layer.cornerRadius = 8
        contentView.addSubview(gridImageView)
        
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        contentView.addSubview(titleLabel)
        
        ratingLabel.textAlignment = .left
        ratingLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(ratingLabel)
        
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .fillEqually
        ratingStackView.spacing = 2
        contentView.addSubview(ratingStackView)
        
        bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .selected)
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        contentView.addSubview(bookmarkButton)
        
        reviewCountLabel.font = UIFont.systemFont(ofSize: 12)
        reviewCountLabel.textColor = .darkGray
        contentView.addSubview(reviewCountLabel)
        
        [gridImageView, titleLabel, ratingLabel, ratingStackView, bookmarkButton, reviewCountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            gridImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gridImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            gridImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            gridImageView.heightAnchor.constraint(equalToConstant: 110),
            
            titleLabel.topAnchor.constraint(equalTo: gridImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            ratingLabel.bottomAnchor.constraint(equalTo: ratingStackView.bottomAnchor),
            
            ratingStackView.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 4),
            ratingStackView.topAnchor.constraint(equalTo: ratingLabel.topAnchor),
            ratingStackView.heightAnchor.constraint(equalToConstant: 14),
            
            bookmarkButton.topAnchor.constraint(equalTo: gridImageView.topAnchor, constant: 5),
            bookmarkButton.leadingAnchor.constraint(equalTo: gridImageView.leadingAnchor, constant: 5),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30),
            
            reviewCountLabel.leadingAnchor.constraint(equalTo: ratingStackView.trailingAnchor, constant: 4),
            reviewCountLabel.topAnchor.constraint(equalTo: ratingStackView.topAnchor),
            reviewCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: ratingStackView.bottomAnchor)
        ])
    }
    
    @objc private func bookmarkTapped() {
        bookmarkButton.isSelected.toggle()
        bookmarkToggleHandler?()
    }
    
    func configure(with bookmark: Bookmark, isBookmarked: Bool) {
        titleLabel.text = bookmark.title
        ratingLabel.text = "\(bookmark.avgRating)"
        reviewCountLabel.text = "(\(bookmark.reviewCount))"
        bookmarkButton.isSelected = !isBookmarked
        
        let imageURL = URL(string: bookmark.image)
        gridImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "placeholder"))
        
        setupStarRating(rating: bookmark.avgRating)
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
