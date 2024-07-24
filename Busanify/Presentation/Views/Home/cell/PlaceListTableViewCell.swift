//
//  PlaceListTableViewCell.swift
//  Busanify
//
//  Created by MadCow on 2024/7/9.
//

import UIKit
import Combine

class PlaceListTableViewCell: UITableViewCell {
    
    private var cancellable = Set<AnyCancellable>()
    private let viewModel = PlaceListViewModel()
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .black
        
        return label
    }()
    lazy var thumbnailImage: UIImageView = {
        let iv = UIImageView()
        iv.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraint()
        
        self.contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setConstraint()
    }
    
    func setConstraint() {
        [nameLabel, thumbnailImage].forEach{
            self.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            thumbnailImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            thumbnailImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            thumbnailImage.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: thumbnailImage.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configureUI(place: Place) async {
        nameLabel.text = place.title
        thumbnailImage.image = await viewModel.loadImage(url: place.image)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable.removeAll()
        thumbnailImage.image = nil
    }
}

