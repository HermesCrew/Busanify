//
//  BookmarkListCell.swift
//  Busanify
//
//  Created by seokyung on 7/22/24.
//
import Foundation
import UIKit
import Kingfisher

class BookmarkListCell: UITableViewCell {
    let listImageView = UIImageView()
    let titleLabel = UILabel()
    let ratingLabel = UILabel()
    let ratingStackView = UIStackView()
    let reviewCountLabel = UILabel()
    let bookmarkButton = UIButton(type: .custom)
    var bookmarkToggleHandler: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        listImageView.contentMode = .scaleAspectFill
        listImageView.clipsToBounds = true
        listImageView.layer.cornerRadius = 8
        contentView.addSubview(listImageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        
        ratingLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(ratingLabel)
        
        ratingStackView.axis = .horizontal
        ratingStackView.distribution = .fillEqually
        ratingStackView.spacing = 2
        contentView.addSubview(ratingStackView)
        
        reviewCountLabel.font = UIFont.systemFont(ofSize: 13)
        reviewCountLabel.textColor = .darkGray
        contentView.addSubview(reviewCountLabel)
        
        bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .selected)
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        contentView.addSubview(bookmarkButton)
        
        [listImageView, titleLabel, ratingLabel, ratingStackView, reviewCountLabel, bookmarkButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            listImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            listImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            listImageView.widthAnchor.constraint(equalToConstant: 110),
            listImageView.heightAnchor.constraint(equalToConstant: 110),
            
            titleLabel.leadingAnchor.constraint(equalTo: listImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            ratingLabel.bottomAnchor.constraint(equalTo: ratingStackView.bottomAnchor),
            
            ratingStackView.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 4),
            ratingStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            ratingStackView.heightAnchor.constraint(equalToConstant: 14),
            
            reviewCountLabel.leadingAnchor.constraint(equalTo: ratingStackView.trailingAnchor, constant: 4),
            reviewCountLabel.topAnchor.constraint(equalTo: ratingStackView.topAnchor),
            reviewCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: ratingStackView.bottomAnchor),
            
            bookmarkButton.topAnchor.constraint(equalTo: listImageView.topAnchor, constant: 5),
            bookmarkButton.leadingAnchor.constraint(equalTo: listImageView.leadingAnchor, constant: 5),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func bookmarkTapped() {
        bookmarkButton.isSelected.toggle()
        bookmarkToggleHandler?()
    }
    
    func configure(with bookmark: Bookmark, isBookmarked: Bool) {
        titleLabel.text = bookmark.title
        ratingLabel.text = String(bookmark.avgRating)
        reviewCountLabel.text = "(\(bookmark.reviewCount))"
        bookmarkButton.isSelected = !isBookmarked
        
        let imageURL = URL(string: bookmark.image)
        listImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "placeholder"))
        
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
