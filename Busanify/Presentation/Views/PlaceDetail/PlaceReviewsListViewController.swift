//
//  PlaceReviewsListViewController.swift
//  Busanify
//
//  Created by 장예진 on 9/23/24.
//

import UIKit
import Combine

class PlaceReviewsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var reviews: [Review]
    private let placeDetailViewModel: PlaceDetailViewModel
    private let reviewViewModel: ReviewViewModel
    private let authViewModel = AuthenticationViewModel.shared
    weak var delegate: PlaceReviewsListViewControllerDelegate?
    weak var placeListDelegate: AddReviewViewControllerDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: ReviewTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        return tableView
    }()
    
    init(reviews: [Review], placeDetailViewModel: PlaceDetailViewModel, reviewViewModel: ReviewViewModel) {
        self.reviews = reviews
        self.placeDetailViewModel = placeDetailViewModel
        self.reviewViewModel = reviewViewModel
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
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

extension PlaceReviewsListViewController: ReviewTableViewCellDelegate {
    
    func didEditReview(_ review: Review) {
        let reviewController = ReviewViewController(reviewViewModel: reviewViewModel, selectedPlace: self.placeDetailViewModel.place)
        reviewController.selectedReview = review
        reviewController.delegate = self
        reviewController.userReviewDelegate = self
        let reviewView = UINavigationController(rootViewController: reviewController)
        present(reviewView, animated: true)
    }
    
    func didDeleteReview(_ review: Review) {
        Task {
            do {
                try await reviewViewModel.deleteReview(id: review.id, token: self.authViewModel.getToken()!)
                placeDetailViewModel.fetchPlace(token: self.authViewModel.getToken()!)
                self.delegate?.didUpdateData()
                
                if let idx = self.reviews.map({ $0.id }).firstIndex(of: review.id) {
                    DispatchQueue.main.async {
                        self.reviews.remove(at: idx)
                        self.tableView.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .fade)
                    }
                }
            } catch {
                print("Failed to delete review: \(error)")
            }
        }
    }
    
    func reportReview(_ review: Review) {
        var alert = UIAlertController()
        
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            alert = UIAlertController(title: NSLocalizedString("reportReview", comment: ""), message: nil, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("writeTheReason", comment: "")
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("report", comment: ""), style: .destructive, handler: { _ in
                let reportReason = alert.textFields?.first?.text ?? "report"
                
                let reportDTO = ReportDTO(reportedContentId: review.id, reportedUserId: review.user.id, content: reportReason, reportType: .review)
                self.reviewViewModel.reportReview(token: self.authViewModel.getToken()!, reportDTO: reportDTO)
            }))
        case .signedOut:
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForBookmark", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func moveToSignInView() {
        let signInVC = SignInViewController()
        show(signInVC, sender: self)
    }
}

protocol PlaceReviewsListViewControllerDelegate: NSObject {
    func didUpdateData()
}

extension PlaceReviewsListViewController: AddReviewViewControllerDelegate {
    func showToastMessage(_ message: String) {
        self.showToast(view, message: message)
    }
    
    func didCreateReview() {
        placeDetailViewModel.fetchPlace(token: authViewModel.getToken())
    }
    
    func updateListView() {
        self.placeListDelegate?.updateListView()
    }
}

extension PlaceReviewsListViewController: UserReviewTableViewCellDelegate {
    func openReviewDeitView(_ review: Review) {}
    
    func didUpdateReview(_ review: Review?) {
        guard let review = review else { return }

        if let idx = self.reviews.map({ $0.id }).firstIndex(of: review.id) {
            let indexPath = IndexPath(row: idx, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ReviewTableViewCell {
                DispatchQueue.main.async {
                    cell.configure(with: review)
                }
            }
        }
    }
}
