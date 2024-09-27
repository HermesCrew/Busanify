//
//  PlaceReviewsListViewController.swift
//  Busanify
//
//  Created by 장예진 on 9/23/24.
//

import UIKit

class PlaceReviewsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let reviews: [Review]
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: ReviewTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        return tableView
    }()
    
    init(reviews: [Review]) {
        self.reviews = reviews
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reviews" 
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.identifier, for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }
        
        let review = reviews[indexPath.row]
        cell.configure(with: review)
        cell.selectionStyle = .none
        return cell
    }
}
