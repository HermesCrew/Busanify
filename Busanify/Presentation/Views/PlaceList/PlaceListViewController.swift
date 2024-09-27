//
//  PlaceListViewController.swift
//  Busanify
//
//  Created by seokyung on 7/1/24.
//

import UIKit
import Combine

class PlaceListViewController: UIViewController {
    private var viewModel: PlaceListViewModel = PlaceListViewModel()
    private let authViewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private let tableView = UITableView()
    private let lang = NSLocalizedString("lang", comment: "")
    var selectedPlaceType: PlaceType? = nil
    var selectedLat: Double = 0
    var selectedLng: Double = 0
    var selectedRadius: Double = 3000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 140
        //tableView.estimatedRowHeight = 120
    }
    
    private func bindViewModel() {
        viewModel.$placeCellModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        authViewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchPlaces()
            }
            .store(in: &cancellables)
    }
    
    private func fetchPlaces() {
        guard let selectedPlaceType = selectedPlaceType else { return }
        viewModel.fetchPlaces(typeId: selectedPlaceType, lang: lang, lat: selectedLat, lng: selectedLng, radius: selectedRadius)
    }
    
    func fetchPlaces(type: PlaceType, lat: CGFloat, lng: CGFloat, radius: CGFloat) {
        viewModel.fetchPlaces(typeId: type, lang: lang, lat: lat, lng: lng, radius: radius)
        selectedPlaceType = type
        selectedLat = lat
        selectedLng = lng
        selectedRadius = radius
    }
    
    private func showLoginAlert() {
        let alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForBookmark", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
            self?.moveToSignInView()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func moveToSignInView() {
        let signInVC = SignInViewController()
        signInVC.modalPresentationStyle = .pageSheet
        present(signInVC, animated: true, completion: nil)
    }
}

extension PlaceListViewController: UITableViewDataSource, UITableViewDelegate, DetailViewControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.placeCellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceTableViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = viewModel.placeCellModels[indexPath.row]
        cell.configure(with: cellViewModel)
        cell.selectionStyle = .none
        
        cell.bookmarkToggleHandler = { [weak self] _ in
            guard let self = self else { return }
            switch self.authViewModel.state {
            case .googleSignedIn, .appleSignedIn:
                Task {
                    do {
                        try await self.viewModel.toggleBookmark(at: indexPath.row)
                        cell.bookmarkButton.isSelected.toggle() // isBookmarked를 값을 매번 가져오지않고 화면 내에서 바뀌도록
                    } catch {
                        print("Failed to create post: \(error)")
                    }
                }
            case .signedOut:
                self.showLoginAlert()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedId = viewModel.placeCellModels[indexPath.row].id
        let placeDetailViewModel = PlaceDetailViewModel(
            placeId: selectedId,
            useCase: PlacesApi()
        )
        
        let reviewViewModel = ReviewViewModel(useCase: ReviewApi())
        
        let placeDetailVC = PlaceDetailViewController(placeDetailViewModel: placeDetailViewModel, reviewViewModel: reviewViewModel)
        placeDetailVC.delegate = self
        placeDetailVC.placeListDelegate = self
        show(placeDetailVC, sender: self)
    }
    
    func didUpdateData() {
        fetchPlaces()
    }
}

extension PlaceListViewController: AddReviewViewControllerDelegate {
    func didCreateReview() {}
    
    func showToastMessage(_ message: String) {}
    
    func updateListView() {
        self.fetchPlaces()
    }
}
