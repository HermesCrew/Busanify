//
//  DetailViewController.swift
//  Busanify
//
//  Created by 이인호 on 7/11/24.
//

import UIKit
import Combine

class PlaceDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel: PlaceDetailViewModel
    private let authViewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private var placeInfos: [(label: String, icon: String)] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceInfoTableViewCell.self, forCellReuseIdentifier: PlaceInfoTableViewCell.identifier)
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: RatingTableViewCell.identifier)
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: ReviewTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        return tableView
    }()
    
    private lazy var placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0 // stackview에서 이거 없으면 안보임
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [placeImageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 10
        
        return stackView
    }()
    
    private lazy var bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        button.addAction(UIAction { [weak self] _ in
            self?.bookmarkTapped()
        }, for: .touchUpInside)
        button.tintColor = .white
        
        return button
    }()
    
    init(viewModel: PlaceDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind()
        
        viewModel.fetchPlace(token: authViewModel.getToken())
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        placeImageView.addSubview(bookmarkButton)
        stackView.addArrangedSubview(placeImageView)
        stackView.addArrangedSubview(titleLabel)
        
        tableView.tableHeaderView = stackView
        tableView.separatorInset = UIEdgeInsets.zero // 라인
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            bookmarkButton.topAnchor.constraint(equalTo: placeImageView.topAnchor, constant: 10),
            bookmarkButton.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: -10),

            stackView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 300),
            
            titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16),
        ])
    }
    
    
    private func bookmarkTapped() {
        viewModel.toggleBookmarkPlace(token: authViewModel.getToken())
        bookmarkButton.isSelected.toggle()
    }
    
    private func bind() {
        viewModel.$place
            .receive(on: DispatchQueue.main)
            .sink { [weak self] place in
                self?.configureViewContents(place: place)
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func configureViewContents(place: Place) {
        self.titleLabel.text = place.title
        self.updatePlaceInfos(place: place)
        
        placeImageView.image = nil
        if let imageURL = URL(string: place.image) {
            loadImage(from: imageURL)
        } else {
            placeImageView.image = UIImage(named: "placeholder")
        }
        bookmarkButton.isSelected = place.isBookmarked
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            
            DispatchQueue.main.async {
                self.placeImageView.image = image
            }
        }.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return placeInfos.count
        case 1: return 1
        case 2: return 3
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaceInfoTableViewCell.identifier, for: indexPath) as? PlaceInfoTableViewCell else {
                return UITableViewCell()
            }
            let placeInfo = placeInfos[indexPath.item]
            cell.configure(with: placeInfo)
            cell.selectionStyle = .none
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RatingTableViewCell.identifier, for: indexPath) as? RatingTableViewCell else {
                return UITableViewCell()
            }
            let rating = viewModel.place.avgRating
            cell.configure(with: rating)
            cell.selectionStyle = .none
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.identifier, for: indexPath) as? ReviewTableViewCell else {
                return UITableViewCell()
            }
            if let reviews = viewModel.place.reviews {
                cell.configure(with: reviews[indexPath.item])
            }
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
//        headerView.backgroundColor = .lightGray
    
        return headerView
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch indexPath.section {
//        case 0:
//            return UITableView.automaticDimension
//        case 1: return 30
//        default: return UITableView.automaticDimension
//        }
//    }
    
    private func updatePlaceInfos(place: Place) {
        var infos = [String]()
        
        // 다국어 추가
        if place.parking != nil {
            infos.append("Parking")
        }
        
        if place.restroom == 1 {
            infos.append("Restroom")
        }
        
        if place.hanok == 1 {
            infos.append("Hanok")
        }
        
        if place.goodStay == 1 {
            infos.append("GoodStay")
        }
        
        let infosString = infos.joined(separator: ", ")
        
        placeInfos = [(place.address, "mappin.and.ellipse"), (place.openTime, "clock"), (place.tel, "phone"), (place.fee, "banknote"), (place.menu, "fork.knife"),
                      (place.shopguide, "bag"), (place.reservationURL, "globe"), (infosString, "info.circle")]
            .compactMap { info in
                if let label = info.0, !label.isEmpty {
                    return (label, info.1)
                } else {
                    return nil
                }
            }
    }
}
