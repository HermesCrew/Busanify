//
//  PhotoCollectionViewCell.swift
//  Busanify
//
//  Created by 이인호 on 9/20/24.
//

import UIKit
import Kingfisher

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var currentIndex: Int? // 현재 인덱스
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        let deleteImage = UIImage(systemName: "x.circle.fill")
        button.setImage(deleteImage, for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = false // 클리핑 해제
            contentView.clipsToBounds = false
        
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
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10), // 상단 여백 줄임
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10), // 우측 여백 줄임
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
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
    
    func configure(with imageUrl: String) {
        let url = URL(string: imageUrl)
        imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "circle.dotted"))
    }
}
