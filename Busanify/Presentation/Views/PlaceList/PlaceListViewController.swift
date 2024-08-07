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
    private let lang = "eng" // 임시
    
//    init(viewModel: PlaceListViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }

//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
//        fetchPlaces()
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
        viewModel.$placeCellViewModels
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
        viewModel.fetchPlaces(typeId: .touristAttraction, lang: lang, lat: 35.07885, lng: 129.04402, radius: 3000)
    }
    
    func fetchPlaces(type: PlaceType, lat: CGFloat, lng: CGFloat) {
        viewModel.fetchPlaces(typeId: type, lang: lang, lat: lat, lng: lng, radius: 3000)
    }
    
    private func showLoginAlert() {
        let alert = UIAlertController(title: "로그인 필요", message: "북마크 기능을 사용하려면 로그인이 필요합니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "로그인", style: .default, handler: { [weak self] _ in
            self?.moveToSignInView()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func moveToSignInView() {
        let signInVC = SignInViewController()
        navigationController?.pushViewController(signInVC, animated: true)
    }
}

extension PlaceListViewController: UITableViewDataSource, UITableViewDelegate, DetailViewControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.placeCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceTableViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = viewModel.placeCellViewModels[indexPath.row]
        cell.configure(with: cellViewModel)
        cell.selectionStyle = .none
        
        cell.bookmarkToggleHandler = { [weak self] _ in
            guard let self = self else { return }
            switch self.authViewModel.state {
            case .googleSignedIn, .appleSignedIn:
                self.viewModel.toggleBookmark(at: indexPath.row)
                cell.bookmarkButton.isSelected.toggle()
            case .signedOut:
                self.showLoginAlert()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedId = viewModel.placeCellViewModels[indexPath.row].id
        let placeDetailViewModel = PlaceDetailViewModel(
            placeId: selectedId,
            useCase: PlacesApi()
        )
        let placeDetailVC = PlaceDetailViewController(viewModel: placeDetailViewModel)
        placeDetailVC.delegate = self
        show(placeDetailVC, sender: self)
    }
    
    func didUpdateData() {
        fetchPlaces()
    }
}
