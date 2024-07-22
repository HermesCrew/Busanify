//
//  BookmarkGridCell.swift
//  Busanify
//
//  Created by seokyung on 7/20/24.
//
/*
 들어가야 하는 그리드셀 정보: 이미지, 이름, 별점?, 북마크 표시
 리스트셀도 같은 정보?
 */
import Foundation
import UIKit

class BookmarkGridCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .systemGray2
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            label.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }

    func configure(with text: String) {
        label.text = text
    }
}
