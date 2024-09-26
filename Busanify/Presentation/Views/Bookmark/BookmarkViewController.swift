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
    let emptyMessageLabel = UILabel()
    var tableView: UITableView?
    var collectionView: UICollectionView?
    var isGridView = true
    private let viewModel = BookmarkViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupCollectionView()
        bindViewModel()
        viewModel.loadBookmarks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadBookmarks()
    }
    
    func bindViewModel() {
        viewModel.$bookmarks
            .combineLatest(viewModel.$isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (bookmarks, isLoading) in
                self?.tableView?.reloadData()
                self?.collectionView?.reloadData()
                self?.showCells()
                
                if isLoading {
                    self?.emptyMessageLabel.isHidden = true
                } else {
                    self?.emptyMessageLabel.isHidden = !bookmarks.isEmpty
                }
            }
            .store(in: &cancellables)
    }
    
    private func showCells() {
        if self.isGridView {
            self.collectionView?.isHidden = viewModel.bookmarks.isEmpty
            self.tableView?.isHidden = true
        } else {
            self.tableView?.isHidden = viewModel.bookmarks.isEmpty
            self.collectionView?.isHidden = true
        }
    }
    
    func setupUI() {
        titleLabel.text = NSLocalizedString("bookmark", comment: "")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        switchLayoutButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        switchLayoutButton.showsMenuAsPrimaryAction = true
        switchLayoutButton.menu = popupMenu()
        switchLayoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchLayoutButton)
        
        emptyMessageLabel.text = NSLocalizedString("bookmarkEmpty", comment: "")
        emptyMessageLabel.font = UIFont.boldSystemFont(ofSize: 20)
        emptyMessageLabel.textColor = .gray
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.isHidden = true
        emptyMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyMessageLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            switchLayoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            switchLayoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            emptyMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - 40) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        view.addSubview(collectionView)
        
        collectionView.register(BookmarkGridCell.self, forCellWithReuseIdentifier: "BookmarkGridCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.collectionView = collectionView
    }
    
    func loadBookmarks() {
        viewModel.loadBookmarks()
        tableView?.reloadData()
        collectionView?.reloadData()
    }
    
    func popupMenu() -> UIMenu {
        let listViewAction = UIAction(title: NSLocalizedString("viewAsList", comment: ""), image: UIImage(systemName: "list.bullet")) { _ in
            self.switchToTableView()
        }
        let gridViewAction = UIAction(title: NSLocalizedString("viewAsGrid", comment: ""), image: UIImage(systemName: "square.grid.2x2")) { _ in
            self.switchToGridView()
        }
        
        return UIMenu(title: "", children: [gridViewAction, listViewAction])
    }
    
    func switchToTableView() {
        isGridView = false
        collectionView?.isHidden = true
        tableView?.isHidden = false
        viewModel.loadBookmarks()
        tableView?.reloadData()
    }
    
    func switchToGridView() {
        isGridView = true
        tableView?.isHidden = true
        collectionView?.isHidden = false
        viewModel.loadBookmarks()
        collectionView?.reloadData()
    }
}

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate, DetailViewControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkListCell", for: indexPath) as! BookmarkListCell
    
        let bookmark = viewModel.bookmarks[indexPath.row]
        let isBookmarked = viewModel.isBookmarked(bookmark.id)
        cell.configure(with: bookmark, isBookmarked: isBookmarked)
        cell.selectionStyle = .none
        cell.bookmarkToggleHandler = {
            Task {
                do {
                    try await self.viewModel.toggleBookmark(at: indexPath.row)
                } catch {
                    print("Failed to create post: \(error)")
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedId = viewModel.bookmarks[indexPath.row].id
        let placeDetailViewModel = PlaceDetailViewModel(
            placeId: selectedId,
            useCase: PlacesApi()
        )
        
        let reviewViewModel = ReviewViewModel(useCase: ReviewApi())
        let placeDetailVC = PlaceDetailViewController(placeDetailViewModel: placeDetailViewModel, reviewViewModel: reviewViewModel)
        placeDetailVC.delegate = self
        placeDetailVC.hidesBottomBarWhenPushed = true
        show(placeDetailVC, sender: self)
    }
    
    func didUpdateData() {
        loadBookmarks()
    }
    
}

extension BookmarkViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.bookmarks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkGridCell", for: indexPath) as! BookmarkGridCell
        let bookmark = viewModel.bookmarks[indexPath.item]
        let isBookmarked = viewModel.isBookmarked(bookmark.id)
        cell.configure(with: bookmark, isBookmarked: isBookmarked)
        cell.bookmarkToggleHandler = {
            Task {
                do {
                    try await self.viewModel.toggleBookmark(at: indexPath.row)
                } catch {
                    print("Failed to create post: \(error)")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedId = viewModel.bookmarks[indexPath.row].id
        let placeDetailViewModel = PlaceDetailViewModel(
            placeId: selectedId,
            useCase: PlacesApi()
        )
        
        let reviewViewModel = ReviewViewModel(useCase: ReviewApi())
        let placeDetailVC = PlaceDetailViewController(placeDetailViewModel: placeDetailViewModel, reviewViewModel: reviewViewModel)
        placeDetailVC.delegate = self
        show(placeDetailVC, sender: self)
    }
}
