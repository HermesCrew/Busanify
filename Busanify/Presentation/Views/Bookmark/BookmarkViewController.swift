//
//  BookmarkViewController.swift
//  Busanify
//
//  Created by seokyung on 7/20/24.
//

import UIKit

class BookmarkViewController: UIViewController {
    let titleLabel = UILabel()
    let switchLayoutButton = UIButton(type: .system)
    var tableView: UITableView! //수정
    var collectionView: UICollectionView! //수정
    var isGridView = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupCollectionView()
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
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            switchLayoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            switchLayoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BookmarkCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        collectionView.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func switchToGridView() {
        isGridView = true
        tableView.isHidden = true
        collectionView.isHidden = false
        collectionView.reloadData()
    }
}

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath)
        cell.textLabel?.text = "Bookmark \(indexPath.row + 1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BookmarkViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkGridCell", for: indexPath) as! BookmarkGridCell
        cell.configure(with: "Bookmark \(indexPath.row + 1)")
        return cell
    }
}
