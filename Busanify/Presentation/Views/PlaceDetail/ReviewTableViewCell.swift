//
//  ReviewTableViewCell.swift
//  Busanify
//
//  Created by 이인호 on 7/18/24.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    static let identifier = "review"
    
    private let nicknameLabel = UILabel()
    private let contentLabel = UILabel()
    private let dateLabel = UILabel()
    
    private lazy var starBackgroundStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private lazy var starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        backgroundStars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(starBackgroundStackView)
        contentView.addSubview(starStackView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(moreButton)
        
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        starBackgroundStackView.translatesAutoresizingMaskIntoConstraints = false
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
    
        ])
    }
    
    func configure(with review: Review) {
        nicknameLabel.text = review.username
        contentLabel.text = review.content
        dateLabel.text = review.createdAt
        setUpStars(rating: review.rating)
    }
    
    private func backgroundStars() {
        for _ in 0..<5 {
            let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = .gray
            starBackgroundStackView.addArrangedSubview(starImageView)
        }
    }
    
    private func setUpStars(rating: Double) {
        for _ in 0..<5 {
            let starImageView = StarImageView(image: UIImage(systemName: "star.fill"))
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = .black
            starStackView.addArrangedSubview(starImageView)
        }
        
        var rating = rating
        for i in 0..<5 {
            if rating < 0 {
                break
            }
            
            let percentage = min(rating, 1)
            updateStarFill(at: i, percentage: percentage)
            rating -= percentage
        }
    }
    
    private func updateStarFill(at index: Int, percentage: CGFloat) {
        guard let starImageView = starStackView.arrangedSubviews[index] as? StarImageView else { return }
        starImageView.fillPercentage = percentage
    }
}
