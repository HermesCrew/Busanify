//
//  PhotoCollectionViewCell.swift
//  Busanify
//
//  Created by 이인호 on 9/20/24.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var currentIndex: Int? // 현재 인덱스
    var images: [UIImage]? // 이미지 URL 배열
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        let deleteImage = UIImage(systemName: "minus.circle.fill")
        button.setImage(deleteImage, for: .normal)
        button.tintColor = .red
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 이미지 뷰 제약 조건
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5), // 상단 여백 줄임
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5), // 우측 여백 줄임
            deleteButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.22), // 크기 증가
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor) // 정사각형 유지
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀의 상태 초기화
        imageView.image = nil
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
    }
    
    func configure(with images: [UIImage], index: Int) {
        imageView.image = images[index]
        self.currentIndex = index
        self.images = images // 이미지 URL 배열 설정
    }
}
