//
//  ReviewTableViewCell.swift
//  Busanify
//
//  Created by 이인호 on 7/18/24.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    static let identifier = "review"
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return label
    }()
    
    private let contentLabel = UILabel()
    
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
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.textColor = .gray
    
        return label
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
//        profileImage.layer.cornerRadius = 15
        contentView.addSubview(profileImage)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(starBackgroundStackView)
        contentView.addSubview(starStackView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(moreButton)
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        starBackgroundStackView.translatesAutoresizingMaskIntoConstraints = false
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImage.widthAnchor.constraint(equalTo: usernameLabel.heightAnchor),
            profileImage.heightAnchor.constraint(equalTo: usernameLabel.heightAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            
            starBackgroundStackView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            starBackgroundStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            starBackgroundStackView.widthAnchor.constraint(equalToConstant: 50),
            
            starStackView.topAnchor.constraint(equalTo: starBackgroundStackView.topAnchor),
            starStackView.leadingAnchor.constraint(equalTo: starBackgroundStackView.leadingAnchor),
            starStackView.trailingAnchor.constraint(equalTo: starBackgroundStackView.trailingAnchor),
            starStackView.bottomAnchor.constraint(equalTo: starBackgroundStackView.bottomAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: starBackgroundStackView.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    
    
    func configure(with review: Review) {
        // 리뷰에 user image 추가
        profileImage.image = UIImage(data: review.userProfileImage)
        usernameLabel.text = review.username
        contentLabel.text = review.content
        dateLabel.text = review.createdAt
        
        setUpStars(rating: review.rating)
    }
    
    private func backgroundStars() {
        starBackgroundStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for _ in 0..<5 {
            let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = .gray
            starBackgroundStackView.addArrangedSubview(starImageView)
        }
    }
    
    private func setUpStars(rating: Double) {
        starStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var rating = rating
        for i in 0..<5 {
            let starImageView = StarImageView(image: UIImage(systemName: "star.fill"))
            starImageView.contentMode = .scaleAspectFit
            starStackView.addArrangedSubview(starImageView)
            
            if rating > 0 {
                let percentage = min(rating, 1)
                updateStarFill(at: i, percentage: percentage)
                rating -= percentage
            }
        }
    }
    
    private func updateStarFill(at index: Int, percentage: CGFloat) {
        guard let starImageView = starStackView.arrangedSubviews[index] as? StarImageView else { return }
        starImageView.fillPercentage = percentage
        starImageView.tintColor = .black
    }
}
