//
//  ReviewTableViewCell.swift
//  Busanify
//
//  Created by 이인호 on 7/18/24.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    static let identifier = "review"
    private let authViewModel = AuthenticationViewModel.shared
    private let keyChain = Keychain()
    
    weak var delegate: ReviewTableViewCellDelegate?
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return label
    }()
    
    private let contentLabel = UILabel()
    
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
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        
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
        profileImage.layer.cornerRadius = 15
        contentView.addSubview(profileImage)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(starStackView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(moreButton)
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImage.widthAnchor.constraint(equalToConstant: 30),
            profileImage.heightAnchor.constraint(equalToConstant: 30),
            
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            usernameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            
            moreButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            
            starStackView.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            starStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            starStackView.widthAnchor.constraint(equalToConstant: 50),
            
            contentLabel.topAnchor.constraint(equalTo: starStackView.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    func configure(with review: Review) {
        profileImage.image = UIImage(data: review.user.profileImage)
        usernameLabel.text = review.user.nickname
        contentLabel.text = review.content
        dateLabel.text = review.createdAt
        
        var menuItems: [UIAction] = [UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.triangle"), handler: { _ in })]
        
        switch authViewModel.state {
        case .googleSignedIn(let user):
            if review.user.id == user.userID {
                menuItems = [
                    UIAction(title: "Modify", image: UIImage(systemName: "pencil"), handler: { _ in }),
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                        self?.delegate?.didDeleteReview(review)
                    })
                ]
            }
        case .appleSignedIn:
            guard let userId = self.keyChain.read(key: "appleUserId") else {
                print("No valid user ID")
                return
            }
            
            if review.user.id == userId {
                menuItems = [
                    UIAction(title: "Modify", image: UIImage(systemName: "pencil"), handler: { _ in }),
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                        self?.delegate?.didDeleteReview(review)
                    })
                ]
            }
        default:
            break
        }
        
        let menu = UIMenu(title: "", image: nil, options: [], children: menuItems)
        moreButton.menu = menu
        
        setupStarRating(rating: review.rating)
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
}

protocol ReviewTableViewCellDelegate: NSObject {
    func didDeleteReview(_ review: Review)
}
