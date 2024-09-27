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
        enableInteractivePopGesture()
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
        title = NSLocalizedString("myReview", comment: "")
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
        
        let selectedReview = viewModel.reviews[indexPath.item]
        
        let placeDetailViewModel = PlaceDetailViewModel(
            placeId: selectedReview.place?.id ?? "",
            useCase: PlacesApi()
        )
        
        let reviewViewModel = ReviewViewModel(useCase: ReviewApi())
        let placeDetailVC = PlaceDetailViewController(placeDetailViewModel: placeDetailViewModel, reviewViewModel: reviewViewModel)
        self.navigationController?.pushViewController(placeDetailVC, animated: true)
    }
}

extension UserReviewViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.loadReviews()
    }
}

extension UserReviewViewController: UserReviewTableViewCellDelegate, AddPostViewControllerDelegate {
    func didDeleteReview(_ review: Review) {
        Task {
            do {
                try await postViewModel.deleteReview(id: review.id, token: AuthenticationViewModel.shared.getToken()!)
                self.viewModel.loadReviews()
            } catch {
                print("Failed to delete review: \(error)")
            }
        }
    }
    
    func openReviewDeitView(_ review: Review) {
        let reviewController = ReviewViewController(reviewViewModel: postViewModel, selectedPlace: review.place!)
        reviewController.selectedReview = review
        reviewController.userReviewDelegate = self
        let reviewView = UINavigationController(rootViewController: reviewController)
        present(reviewView, animated: true)
    }
    
    func didUpdateReview(_ review: Review? = nil) {
        self.viewModel.loadReviews()
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
