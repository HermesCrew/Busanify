//
//  PlaceListTableViewCell.swift
//  Busanify
//
//  Created by MadCow on 2024/7/9.
//

import UIKit
import Combine

class SelectedPlaceListTableViewCell: UITableViewCell {
    
    private var cancellable = Set<AnyCancellable>()
    private let viewModel = SelectedPlaceListViewModel()
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .black
        
        return label
    }()
    private let bookmarkButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        
        return btn
    }()
    private let averagePointLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private lazy var averageStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.addArrangedSubview(self.averagePointLabel)
        
        return stack
    }()
    lazy var thumbnailImage: UIImageView = {
        let iv = UIImageView()
        iv.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setConstraint()
        self.setButtonAction()
        
        self.contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setConstraint()
        self.setButtonAction()
    }
    
    func setConstraint() {
        [nameLabel, bookmarkButton, averagePointLabel, thumbnailImage].forEach{
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -8),
            
            bookmarkButton.topAnchor.constraint(equalTo: self.nameLabel.topAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            
            averagePointLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 8),
            averagePointLabel.leadingAnchor.constraint(equalTo: self.nameLabel.leadingAnchor),
            
            thumbnailImage.topAnchor.constraint(equalTo: self.averagePointLabel.bottomAnchor, constant: 5),
            thumbnailImage.leadingAnchor.constraint(equalTo: self.averagePointLabel.leadingAnchor),
            thumbnailImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
            
//            nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
//            nameLabel.leadingAnchor.constraint(equalTo: thumbnailImage.trailingAnchor, constant: 10),
//            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func setButtonAction() {
        bookmarkButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.bookmarkButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        }, for: .touchUpInside)
    }
    
    func configureUI(place: Place) async {
        nameLabel.text = place.title
        averagePointLabel.text = "별점: \(place.avgRating)"
        thumbnailImage.image = await viewModel.loadImage(url: place.image)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.removeAll()
        thumbnailImage.image = nil
    }
}

