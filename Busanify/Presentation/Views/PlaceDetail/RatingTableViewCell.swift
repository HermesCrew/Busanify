//
//  RatingTableViewCell.swift
//  Busanify
//
//  Created by 이인호 on 7/18/24.
//

import UIKit

class RatingTableViewCell: UITableViewCell {
    
    static let identifier = "rating"
    var reviewDelegate: MoveToReviewView?
    
    private let ratingLabel = UILabel()
    
    private lazy var starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private lazy var addReviewButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.addAction(UIAction { [weak self] _ in
            // 버튼 클릭시 리뷰 작성 뷰로 이동
            guard let self = self else { return }
            self.reviewDelegate?.moveToReviewView()
        }, for: .touchUpInside)
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        ratingLabel.font = UIFont.systemFont(ofSize: 24)
        
        contentView.addSubview(ratingLabel)
        contentView.addSubview(starStackView)
        contentView.addSubview(addReviewButton)
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        addReviewButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            ratingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ratingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            starStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            starStackView.leadingAnchor.constraint(equalTo: ratingLabel.trailingAnchor, constant: 8),
            starStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            addReviewButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            addReviewButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addReviewButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupStarRating(rating: Double) {
        starStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 0..<5 {
            let starImageView = UIImageView()
            starImageView.contentMode = .scaleAspectFit
            
            let fillRatio = min(max(rating - Double(i), 0), 1)
            
            let filledStarImage = drawPartialStar(fillRatio: CGFloat(fillRatio))
            starImageView.image = filledStarImage
            
            starStackView.addArrangedSubview(starImageView)
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
    
    func configure(with rating: Double) {
        ratingLabel.text = String(format: "%.1f", rating)
        setupStarRating(rating: rating)
    }
}
