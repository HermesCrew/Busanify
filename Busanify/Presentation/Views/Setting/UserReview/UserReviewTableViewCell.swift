//
//  UserReviewTableViewCell.swift
//  Busanify
//
//  Created by seokyung on 9/27/24.
//
import UIKit
import Kingfisher

class UserReviewTableViewCell: UITableViewCell {
    
    static let identifier = "review"
    private let authViewModel = AuthenticationViewModel.shared
    private let keyChain = Keychain()
    var photoUrls: [String] = []
    
    weak var delegate: UserReviewTableViewCellDelegate?
    
    private lazy var placenameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1
        
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
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
        contentView.addSubview(placenameLabel)
        contentView.addSubview(starStackView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(moreButton)
        
        placenameLabel.translatesAutoresizingMaskIntoConstraints = false
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placenameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            placenameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placenameLabel.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8),
            
            moreButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: placenameLabel.centerYAnchor),
            
            starStackView.topAnchor.constraint(equalTo: placenameLabel.bottomAnchor, constant: 8),
            starStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            starStackView.widthAnchor.constraint(equalToConstant: 50),
            
            contentLabel.topAnchor.constraint(equalTo: starStackView.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionViewHeightConstraint,
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with review: Review) {
        placenameLabel.text = review.place?.title
        contentLabel.text = review.content
        dateLabel.text = review.createdAt
        
        self.photoUrls = review.photoUrls
        if review.photoUrls.isEmpty {
            collectionViewHeightConstraint.constant = 0
        } else {
            collectionViewHeightConstraint.constant = 100
        }
        
        collectionView.reloadData()
        
        let menuItems: [UIAction] = [
            UIAction(title: NSLocalizedString("edit", comment: ""), image: UIImage(systemName: "pencil"), handler: { [weak self] _ in
                self?.delegate?.openReviewDeitView(review)
            }),
            UIAction(title: NSLocalizedString("delete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                self?.showDeleteConfirmationAlert(for: review)
            })
        ]
        
        
        let menu = UIMenu(title: "", image: nil, options: [], children: menuItems)
        moreButton.menu = menu
        
        setupStarRating(rating: Double(review.rating))
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
    
    private func showDeleteConfirmationAlert(for review: Review) {
        guard let viewController = self.delegate as? UIViewController else { return }
        
        let alert = UIAlertController(title: NSLocalizedString("deleteReview", comment: ""), message: NSLocalizedString("postWillBeDeleted", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didDeleteReview(review)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension UserReviewTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

protocol UserReviewTableViewCellDelegate: NSObject {
    func didDeleteReview(_ review: Review)
    func openReviewDeitView(_ review: Review)
    func reportReview(_ review: Review)
    func didUpdateReview()
}
