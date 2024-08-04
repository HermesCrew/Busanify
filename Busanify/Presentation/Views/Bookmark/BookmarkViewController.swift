//
//  BookmarkViewController.swift
//  Busanify
//
//  Created by seokyung on 7/20/24.
//

import UIKit
import Combine

class BookmarkViewController: UIViewController {
    let titleLabel = UILabel()
    let switchLayoutButton = UIButton(type: .system)
    var tableView: UITableView?
    var collectionView: UICollectionView?
    var isGridView = false
    var bookmarks: [Bookmark] = []
    private var cancellables = Set<AnyCancellable>()
    private let placesApi = PlacesApi()
    private let lang = "eng"  // user language

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupCollectionView()
        loadBookmarks()
    }

    func setupUI() {
        titleLabel.text = "Bookmarks"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        switchLayoutButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        switchLayoutButton.showsMenuAsPrimaryAction = true
        switchLayoutButton.menu = popupMenu()
        switchLayoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchLayoutButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            switchLayoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            switchLayoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    func setupTableView() {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.register(BookmarkListCell.self, forCellReuseIdentifier: "BookmarkListCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 140
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.tableView = tableView
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 170)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        view.addSubview(collectionView)
        
        collectionView.register(BookmarkGridCell.self, forCellWithReuseIdentifier: "BookmarkGridCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.collectionView = collectionView
    }

    func loadBookmarks() {
        guard let token = AuthenticationViewModel.shared.getToken() else { return }
        
        placesApi.getBookmarkedPlaces(token: token, lang: lang)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading bookmarks: \(error)")
                }
            }, receiveValue: { [weak self] bookmarks in
                self?.bookmarks = bookmarks
                self?.tableView?.reloadData()
                self?.collectionView?.reloadData()
            })
            .store(in: &cancellables)
    }

    func popupMenu() -> UIMenu {
        let listViewAction = UIAction(title: "리스트로 보기", image: UIImage(systemName: "list.bullet")) { _ in
            self.switchToTableView()
        }
        let gridViewAction = UIAction(title: "그리드로 보기", image: UIImage(systemName: "square.grid.2x2")) { _ in
            self.switchToGridView()
        }
        
        return UIMenu(title: "", children: [listViewAction, gridViewAction])
    }
    
    func switchToTableView() {
        isGridView = false
        collectionView?.isHidden = true
        tableView?.isHidden = false
        tableView?.reloadData()
    }
    
    func switchToGridView() {
        isGridView = true
        tableView?.isHidden = true
        collectionView?.isHidden = false
        collectionView?.reloadData()
    }
}

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate, DetailViewControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkListCell", for: indexPath) as! BookmarkListCell
        let bookmark = bookmarks[indexPath.row]
        cell.configure(with: bookmark)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedId = bookmarks[indexPath.row].id
        let placeDetailViewModel = PlaceDetailViewModel(
            placeId: selectedId,
            useCase: PlacesApi()
        )
        let placeDetailVC = PlaceDetailViewController(viewModel: placeDetailViewModel)
        placeDetailVC.delegate = self
        show(placeDetailVC, sender: self)
    }
    
    func didUpdateData() {
        loadBookmarks()
    }
    
}

extension BookmarkViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkGridCell", for: indexPath) as! BookmarkGridCell
        let bookmark = bookmarks[indexPath.item]
        cell.configure(with: bookmark)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedId = bookmarks[indexPath.row].id
        let placeDetailViewModel = PlaceDetailViewModel(
            placeId: selectedId,
            useCase: PlacesApi()
        )
        let placeDetailVC = PlaceDetailViewController(viewModel: placeDetailViewModel)
        placeDetailVC.delegate = self
        show(placeDetailVC, sender: self)
    }
}
