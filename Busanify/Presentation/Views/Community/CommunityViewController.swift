//
//  CommunityViewController.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import UIKit
import Combine

class CommunityViewController: UIViewController  {
    private let postViewModel = PostViewModel(useCase: PostApi())
    private let authViewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction { [weak self] _ in
            self?.postViewModel.fetchPosts()
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }, for: .valueChanged)
        
        return refreshControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: CommunityTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.refreshControl = refreshControl
        
        return tableView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Community"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        
        return label
    }()
    
    private lazy var addPostButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        
        button.addAction(UIAction { [weak self] _ in
            self?.addButtonTapped()
        }, for: .touchUpInside)
        return button
    }()
    
    private let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Be the first to write a post!"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .gray
        label.textAlignment = .center
        label.isHidden = true
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        bind()
        
        postViewModel.fetchPosts()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(addPostButton)
        view.addSubview(emptyMessageLabel)
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addPostButton.translatesAutoresizingMaskIntoConstraints = false
        emptyMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            addPostButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func addButtonTapped() {
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            let postViewModel = PostViewModel(useCase: PostApi())
            let addPostVC = AddPostViewController(postViewModel: postViewModel)
            addPostVC.delegate = self
            addPostVC.hidesBottomBarWhenPushed = true // 탭바 숨기기
            self.navigationController?.pushViewController(addPostVC, animated: true)
        case .signedOut:
            let alert = UIAlertController(title: "Need Login", message: "You need to login to write Post", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func moveToSignInView() {
        let signInVC = SignInViewController()
        present(signInVC, animated: true, completion: nil)
    }
    
    private func bind() {
        postViewModel.$posts
            .combineLatest(postViewModel.$isLoading)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (posts, isLoading) in
                self?.tableView.reloadData()
                if isLoading {
                    self?.emptyMessageLabel.isHidden = true
                } else {
                    // 로딩 완료 후, posts 상태에 따라 emptyMessageLabel을 숨기거나 표시
                    self?.emptyMessageLabel.isHidden = !posts.isEmpty
                }
            }
            .store(in: &cancellables)
        
        authViewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        authViewModel.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentUser in
                self?.postViewModel.fetchPosts()
            }
            .store(in: &cancellables)
    }
}

extension CommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postViewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommunityTableViewCell.identifier, for: indexPath) as? CommunityTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: postViewModel.posts[indexPath.item])
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
}

extension CommunityViewController: CommunityTableViewCellDelegate {
    func didDeletePost(_ post: Post) {
        Task {
            do {
                if let index = self.postViewModel.posts.firstIndex(where: { $0.id == post.id }) {
                    tableView.beginUpdates()
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    postViewModel.posts.remove(at: index)
                    tableView.endUpdates()
                }
                
                try await postViewModel.deletePost(token: self.authViewModel.getToken()!, id: post.id, photoUrls: post.photoUrls)
            } catch {
                print("Failed to delete review: \(error)")
            }
        }
    }
    
    func updatePost(_ post: Post) {
        let postViewModel = PostViewModel(useCase: PostApi())
        let addPostVC = UpdatePostViewController(postViewModel: postViewModel, post: post)
        addPostVC.delegate = self
        addPostVC.hidesBottomBarWhenPushed = true // 탭바 숨기기
        self.navigationController?.pushViewController(addPostVC, animated: true)
    }
    
    func reportPost(_ post: Post) {
        var alert = UIAlertController()
        
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            alert = UIAlertController(title: "Report post", message: nil, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Please write the reason"
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { _ in
                let reportReason = alert.textFields?.first?.text ?? "report"
                
                let reportDTO = ReportDTO(reportedContentId: post.id, reportedUserId: post.user.id, content: reportReason, reportType: .post)
                self.postViewModel.reportPost(token: self.authViewModel.getToken()!, reportDTO: reportDTO)
            }))
        case .signedOut:
            alert = UIAlertController(title: "Need Login", message: "You need to login for Report", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func expandPost(cell: CommunityTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func commentButtonTapped(_ post: Post) {
        let commentViewModel = CommentViewModel(useCase: CommentApi())
        let sheetViewController = CommentViewController(commentViewModel: commentViewModel, postViewModel: postViewModel, post: post)
        // 시트 프레젠테이션 설정
        if let sheet = sheetViewController.sheetPresentationController {
            sheet.detents = [.medium()] // 시트 크기 설정
            sheet.prefersGrabberVisible = true // 그랩바 표시
        }
        
        self.present(sheetViewController, animated: true, completion: nil)
    }
}

extension CommunityViewController: AddPostViewControllerDelegate {
    func didCreatePost() {
        postViewModel.fetchPosts()
    }
}
