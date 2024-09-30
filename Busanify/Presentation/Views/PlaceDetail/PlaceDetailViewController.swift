//
//  DetailViewController.swift
//  Busanify
//
//  Created by 이인호 on 7/11/24.
//

import UIKit
import Combine

class PlaceDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let placeDetailViewModel: PlaceDetailViewModel
    private let reviewViewModel: ReviewViewModel
    private let authViewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private var placeInfos: [(label: String, icon: String)] = []
    weak var delegate: DetailViewControllerDelegate?
    weak var placeListDelegate: AddReviewViewControllerDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceInfoTableViewCell.self, forCellReuseIdentifier: PlaceInfoTableViewCell.identifier)
        tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: RatingTableViewCell.identifier)
        tableView.register(ReviewTableViewCell.self, forCellReuseIdentifier: ReviewTableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reviewList")
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
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [placeImageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 15
        return stackView
    }()
    
    private lazy var titleContainerView: UIView = {
        let view = UIView()
        view.addSubview(titleLabel)
        return view
    }()
    
    private lazy var bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        button.addAction(UIAction { [weak self] _ in
            self?.bookmarkTapped()
        }, for: .touchUpInside)
        
        return button
    }()
    
    init(placeDetailViewModel: PlaceDetailViewModel, reviewViewModel: ReviewViewModel) {
        self.placeDetailViewModel = placeDetailViewModel
        self.reviewViewModel = reviewViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        enableInteractivePopGesture()
        configureUI()
        bind()
        
        placeDetailViewModel.fetchPlace(token: authViewModel.getToken())
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        placeImageView.addSubview(bookmarkButton)
        stackView.addArrangedSubview(placeImageView)
        stackView.addArrangedSubview(titleContainerView)
        
        tableView.tableHeaderView = stackView
        tableView.separatorInset = UIEdgeInsets.zero // 라인
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        
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

            placeImageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            placeImageView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            titleContainerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            titleContainerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: titleContainerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor, constant: -15)
        ])
    }
    
    private func bookmarkTapped() {
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            Task {
                do {
                    try await placeDetailViewModel.toggleBookmarkPlace(token: authViewModel.getToken())
                    bookmarkButton.isSelected.toggle() // isBookmarked를 값을 매번 가져오지않고 화면 내에서 바뀌도록
                    delegate?.didUpdateData() // 디테일 뷰에서 이전 뷰로 돌아갈때 변경사항을 업데이트해줌
                } catch {
                    print("Failed to create post: \(error)")
                }
            }
        case .signedOut:
            showLoginAlert()
        }
    }
    
    private func showLoginAlert() {
        let alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForBookmark", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
            self?.moveToSignInView()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func bind() {
        placeDetailViewModel.$place
            .receive(on: DispatchQueue.main)
            .sink { [weak self] place in
                self?.configureViewContents(place: place)
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        authViewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.placeDetailViewModel.fetchPlace(token: self?.authViewModel.getToken())
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
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 장소 정보
            return placeInfos.count
        case 1: // 리뷰 정보
            return 1
        case 2: // 리뷰들
            guard let reviews = placeDetailViewModel.place.reviews else { return 0 }
            return min(reviews.count, 3)
        case 3:
            guard let reviews = placeDetailViewModel.place.reviews else { return 0 }
            return reviews.count <= 3 ? 0 : 1 // 3개 이하일땐 더보기 필요없음
        default:
            return 0
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
            let rating = placeDetailViewModel.place.avgRating
            cell.reviewDelegate = self
            cell.configure(with: rating)
            cell.selectionStyle = .none
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.identifier, for: indexPath) as? ReviewTableViewCell else {
                return UITableViewCell()
            }
            if let reviews = placeDetailViewModel.place.reviews {
                cell.configure(with: reviews[indexPath.item])
                cell.delegate = self
            }
            cell.selectionStyle = .none
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewList", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = NSLocalizedString("viewAllReviews", comment: "")
            content.textProperties.color = .systemBlue
            content.textProperties.alignment = .center
        
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3:
            if indexPath.row == 0 {
                // "View all reviews" 셀을 눌렀을 때
                guard let reviews = placeDetailViewModel.place.reviews else { return }
                let reviewsListVC = PlaceReviewsListViewController(reviews: reviews, placeDetailViewModel: placeDetailViewModel, reviewViewModel: reviewViewModel)
                reviewsListVC.delegate = self
                reviewsListVC.placeListDelegate = self
                present(reviewsListVC, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("info", comment: "")
        case 1: return NSLocalizedString("review", comment: "")
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1: return 50
        default: return 0
        }
    }
    
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

extension PlaceDetailViewController: ReviewTableViewCellDelegate {
    
    func didEditReview(_ review: Review) {
        let reviewController = ReviewViewController(reviewViewModel: reviewViewModel, selectedPlace: self.placeDetailViewModel.place)
        reviewController.selectedReview = review
        reviewController.delegate = self
        let reviewView = UINavigationController(rootViewController: reviewController)
        present(reviewView, animated: true)
    }
    
    func didDeleteReview(_ review: Review) {
        Task {
            do {
                try await reviewViewModel.deleteReview(id: review.id, token: self.authViewModel.getToken()!)
                placeDetailViewModel.fetchPlace(token: self.authViewModel.getToken()!)
                self.delegate?.didUpdateData()
            } catch {
                print("Failed to delete review: \(error)")
            }
        }
    }
    
    func reportReview(_ review: Review) {
        var alert = UIAlertController()
        
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            alert = UIAlertController(title: NSLocalizedString("reportContent", comment: ""), message: nil, preferredStyle: .actionSheet)
            
            // 각 신고 사유에 대한 선택지를 추가
            alert.addAction(UIAlertAction(title: NSLocalizedString("misinformation", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(review: review, reason: "misinformation")
                self.showReportConfirmationAlert()
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("advertisement", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(review: review, reason: "advertisement")
                self.showReportConfirmationAlert()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("pornography", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(review: review, reason: "pornography")
                self.showReportConfirmationAlert()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("violence", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(review: review, reason: "violence")
                self.showReportConfirmationAlert()
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("other", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(review: review, reason: "other")
                self.showReportConfirmationAlert()
            }))

            // 취소 버튼 추가
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        case .signedOut:
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForBookmark", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleReportReason(review: Review, reason: String) {
        let reportDTO = ReportDTO(reportedContentId: review.id, reportedUserId: review.user.id, content: reason, reportType: .review)
        self.reviewViewModel.reportReview(token: self.authViewModel.getToken()!, reportDTO: reportDTO)
    }
    
    func showReportConfirmationAlert() {
        let confirmationAlert = UIAlertController(title: NSLocalizedString("reportSubmitted", comment: ""), message: NSLocalizedString("reportSubmittedMessage", comment: ""), preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK"), style: .default, handler: nil))
        
        self.present(confirmationAlert, animated: true, completion: nil)
    }
}

extension PlaceDetailViewController: MoveToReviewView {
    func moveToReviewView() {
        if authViewModel.state == .signedOut {
            var alert = UIAlertController()
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForWriteReview", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let reviewViewModel = ReviewViewModel(useCase: ReviewApi())
            let reviewController = ReviewViewController(reviewViewModel: reviewViewModel, selectedPlace: self.placeDetailViewModel.place)
            reviewController.delegate = self
            let reviewView = UINavigationController(rootViewController: reviewController)
            present(reviewView, animated: true)
        }
    }
    
    func moveToSignInView() {
        let signInVC = SignInViewController()
        show(signInVC, sender: self)
    }
}

protocol DetailViewControllerDelegate: NSObject {
    func didUpdateData()
}


extension PlaceDetailViewController: AddReviewViewControllerDelegate {
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

extension PlaceDetailViewController: PlaceReviewsListViewControllerDelegate {
    func didUpdateData() {
        placeDetailViewModel.fetchPlace(token: authViewModel.getToken())
    }
}
