//
//  UserPostViewController.swift
//  Busanify
//
//  Created by seokyung on 9/25/24.
//

import UIKit
import Combine

class UserReviewViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = UserReviewViewModel()
    private let postViewModel = ReviewViewModel(useCase: ReviewApi())
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.loadReviews()
    }
    
    func bindViewModel() {
        viewModel.$reviews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reviews in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        tableView.register(UserReviewTableViewCell.self, forCellReuseIdentifier: UserReviewTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "My Review"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension UserReviewViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserReviewTableViewCell.identifier, for: indexPath) as? UserReviewTableViewCell else {
            return UITableViewCell()
        }
        let review = viewModel.reviews[indexPath.row]
        cell.configure(with: review)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserReviewViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.loadReviews()
    }
}

extension UserReviewViewController: UserReviewTableViewCellDelegate, AddPostViewControllerDelegate {
    func didDeleteReview(_ review: Review) {
        //
    }
    
    func didEditReview(_ review: Review) {
        //
    }
    
    func reportReview(_ review: Review) {
        //
    }
    
    func showToastMessage(_ message: String) {
        showToast(view, message: message)
    }
    
    func didCreatePost() {
        //
    }
    
}
