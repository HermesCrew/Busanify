//
//  CommentTableViewCell.swift
//  Busanify
//
//  Created by 이인호 on 9/23/24.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    static let identifier = "comment"
    private let authViewModel = AuthenticationViewModel.shared
    private let keyChain = Keychain()
    
    weak var delegate: CommentTableViewCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
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
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.textColor = .gray
    
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
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
        profileImageView.layer.cornerRadius = 15
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(moreButton)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 8),
            dateLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            moreButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with comment: Comment) {
        if let profileImage = comment.user.profileImage {
            let url = URL(string: profileImage)
            profileImageView.kf.setImage(with: url)
        }
        usernameLabel.text = comment.user.nickname
        contentLabel.text = comment.content
        dateLabel.text = comment.createdAt
        
        var menuItems: [UIAction] = [
            UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.triangle"), handler: { _ in
                self.delegate?.reportComment(comment)
            })
        ]
        
        switch authViewModel.state {
        case .googleSignedIn(let user):
            if comment.user.id == user.userID {
                menuItems = [
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                        self?.delegate?.didDeleteComment(comment)
                    })
                ]
            }
        case .appleSignedIn:
            guard let userId = self.keyChain.read(key: "appleUserId") else {
                print("No valid user ID")
                return
            }
            
            if comment.user.id == userId {
                menuItems = [
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                        self?.delegate?.didDeleteComment(comment)
                    })
                ]
            }
        default:
            break
        }
        
        moreButton.menu = UIMenu(children: menuItems)
    }
}

protocol CommentTableViewCellDelegate: NSObject {
    func didDeleteComment(_ comment: Comment)
    func reportComment(_ comment: Comment)
}
