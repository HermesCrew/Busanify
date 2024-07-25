//
//  BookmarkGridCell.swift
//  Busanify
//
//  Created by seokyung on 7/20/24.
//
// 아이템 크기랑 위치 고민
import Foundation
import UIKit

class BookmarkGridCell: UICollectionViewCell {
    let gridImageView = UIImageView()
    let titleLabel = UILabel()
    let ratingLabel = UILabel()
    let ratingStackView = UIStackView()
    //let reviewCountLabel = UILabel()

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
        
//        reviewCountLabel.font = UIFont.systemFont(ofSize: 14)
//        reviewCountLabel.textColor = .darkGray
//        contentView.addSubview(reviewCountLabel)
        
        [gridImageView, titleLabel, ratingLabel, ratingStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            gridImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gridImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            gridImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            gridImageView.heightAnchor.constraint(equalToConstant: 110),
            gridImageView.widthAnchor.constraint(equalToConstant: 110),

            titleLabel.topAnchor.constraint(equalTo: gridImageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            ratingLabel.bottomAnchor.constraint(equalTo: ratingStackView.bottomAnchor),
            
            ratingStackView.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 4),
            ratingStackView.topAnchor.constraint(equalTo: ratingLabel.topAnchor),
            ratingStackView.heightAnchor.constraint(equalToConstant: 14),
            
//            reviewCountLabel.leadingAnchor.constraint(equalTo: ratingStackView.trailingAnchor, constant: 4),
//            reviewCountLabel.topAnchor.constraint(equalTo: ratingStackView.topAnchor),
//            reviewCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: ratingStackView.bottomAnchor)
        ])
    }

    func configure(with bookmark: Bookmark) {
        titleLabel.text = bookmark.title
        ratingLabel.text = "\(bookmark.avgRating)"
        //reviewCountLabel.text = "(\(bookmark.reviewCount))"
        
        gridImageView.image = nil
        if let imageURL = URL(string: bookmark.image) {
            loadImage(from: imageURL)
        } else {
            gridImageView.image = UIImage(systemName: "photo.fill")
        }
        
        setupStarRating(rating: bookmark.avgRating)
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
                self.gridImageView.image = image
            }
        }.resume()
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
