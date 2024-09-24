//
//  CommunityTableViewCell.swift
//  Busanify
//
//  Created by 이인호 on 9/20/24.
//

import UIKit

class CommunityTableViewCell: UITableViewCell {
    static let identifier = "community"
    private let authViewModel = AuthenticationViewModel.shared
    private let keyChain = Keychain()
    var photoUrls: [String] = []
    private var post: Post?
    private var isExpanded = false
    
    weak var delegate: CommunityTableViewCellDelegate?
    
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
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.lineBreakMode = .byTruncatingTail
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 100, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
                
        return collectionView
    }()
    
    private lazy var collectionViewHeightConstraint: NSLayoutConstraint = {
        return collectionView.heightAnchor.constraint(equalToConstant: 100) // 기본 높이 100
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
    
    private lazy var commentButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "bubble.right")
        config.title = "Comment"
        config.imagePadding = 4 // 이미지와 텍스트 사이의 간격
        config.baseForegroundColor = .black
        config.buttonSize = .small
        
        let button = UIButton(configuration: config)
        button.addAction(UIAction { [weak self] _ in
            guard let post = self?.post else { return }
            self?.delegate?.commentButtonTapped(post)
        }, for: .touchUpInside)
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContentLabel))
        contentLabel.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapContentLabel() {
        if contentLabel.numberOfLines == 0 {
            contentLabel.numberOfLines = 5
        } else {
            contentLabel.numberOfLines = 0
        }
        
        self.delegate?.expandPost(cell: self)
    }
    
    private func configureUI() {
        profileImageView.layer.cornerRadius = 15
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(moreButton)
        contentView.addSubview(commentButton)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionViewHeightConstraint,
            
            commentButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            commentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            commentButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with post: Post) {
        self.post = post
        
        if let profileImage = post.user.profileImage {
            let url = URL(string: profileImage)
            profileImageView.kf.setImage(with: url)
        }
        usernameLabel.text = post.user.nickname
        contentLabel.text = post.content
        dateLabel.text = post.createdAt
        commentButton.setTitle(String(post.commentsCount), for: .normal)
        
        self.photoUrls = post.photoUrls
        if post.photoUrls.isEmpty {
            collectionViewHeightConstraint.constant = 0
        } else {
            collectionViewHeightConstraint.constant = 100
        }
        
        collectionView.reloadData()
        
        var menuItems: [UIAction] = [UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.triangle"), handler: { _ in
            self.delegate?.reportPost(post)
        })
        ]
        
        switch authViewModel.state {
        case .googleSignedIn(let user):
            if post.user.id == user.userID {
                menuItems = [
                    UIAction(title: "Edit", image: UIImage(systemName: "pencil"), handler: { [weak self] _ in
                        self?.delegate?.updatePost(post)
                    }),
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                        self?.delegate?.didDeletePost(post)
                    })
                ]
            }
        case .appleSignedIn:
            guard let userId = self.keyChain.read(key: "appleUserId") else {
                print("No valid user ID")
                return
            }
            
            if post.user.id == userId {
                menuItems = [
                    UIAction(title: "Edit", image: UIImage(systemName: "pencil"), handler: { [weak self] _ in
                        self?.delegate?.updatePost(post)
                    }),
                    UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                        self?.delegate?.didDeletePost(post)
                    })
                ]
            }
        default:
            break
        }
        
        let menu = UIMenu(title: "", image: nil, options: [], children: menuItems)
        moreButton.menu = menu
    }
}

extension CommunityTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
            
        // 기존의 이미지 뷰 제거 (중복 추가 방지)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // 이미지 뷰 생성 및 추가
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        // 이미지 설정
        if let url = URL(string: photoUrls[indexPath.item]) {
            imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "circle.dotted")) // Kingfisher로 이미지 로드
        } else {
            imageView.image = UIImage(systemName: "circle.dotted")
        }
        
        // 이미지 뷰를 셀에 추가
        cell.contentView.addSubview(imageView)
        
        return cell
    }
}

protocol CommunityTableViewCellDelegate: NSObject {
    func didDeletePost(_ post: Post)
    func updatePost(_ post: Post)
    func reportPost(_ post: Post)
    func expandPost(cell: CommunityTableViewCell)
    func commentButtonTapped(_ post: Post)
}
