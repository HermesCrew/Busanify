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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        bind()
        
        postViewModel.fetchPosts()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .done, target: self, action: #selector(addButtonTapped))
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    @objc private func addButtonTapped() {
        let postViewModel = PostViewModel(useCase: PostApi())
        let addPostVC = AddPostViewController(postViewModel: postViewModel)
        addPostVC.delegate = self
        addPostVC.hidesBottomBarWhenPushed = true // 탭바 숨기기
        self.navigationController?.pushViewController(addPostVC, animated: true)
    }
    
    private func moveToSignInView() {
        let signInVC = SignInViewController()
        present(signInVC, animated: true, completion: nil)
    }
    
    private func bind() {
        postViewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        authViewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
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
                try await postViewModel.deletePost(token: self.authViewModel.getToken()!, id: post.id, photoUrls: post.photoUrls)
                postViewModel.fetchPosts()
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
            alert = UIAlertController(title: "로그인 필요", message: "북마크 기능을 사용하려면 로그인이 필요합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "로그인", style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
}

extension CommunityViewController: AddPostViewControllerDelegate {
    func didCreatePost() {
        postViewModel.fetchPosts()
    }
}
