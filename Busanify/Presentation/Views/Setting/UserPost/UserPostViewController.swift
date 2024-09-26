//
//  UserPostViewController.swift
//  Busanify
//
//  Created by seokyung on 9/25/24.
//

import UIKit
import Combine

class UserPostViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = UserPostViewModel()
    private let postViewModel = PostViewModel(useCase: PostApi())
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.loadPosts()
    }
    
    func bindViewModel() {
        viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = NSLocalizedString("myCommunityPost", comment: "")
        
        tableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: CommunityTableViewCell.identifier)
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
}

extension UserPostViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommunityTableViewCell.identifier, for: indexPath) as? CommunityTableViewCell else {
            return UITableViewCell()
        }
        let post = viewModel.posts[indexPath.row]
        cell.configure(with: post)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserPostViewController: CommunityTableViewCellDelegate {
    func showPostDetail(post: Post) {
        let commentViewModel = CommentViewModel(useCase: CommentApi())
        let postViewModel = PostViewModel(useCase: PostApi())
        
        let postDetailVC = PostDetailViewController(post: post, commentViewModel: commentViewModel, postViewModel: postViewModel)
        navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func didDeletePost(_ post: Post) {
        Task {
            do {
                if let token = self.viewModel.validateToken() {
                    if let index = self.postViewModel.posts.firstIndex(where: { $0.id == post.id }) {
                        tableView.beginUpdates()
                        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        postViewModel.posts.remove(at: index)
                        tableView.endUpdates()
                    }
                    
                    try await postViewModel.deletePost(token: token, id: post.id, photoUrls: post.photoUrls)
                    viewModel.loadPosts()
                } else {
                    print("No valid token found")
                }
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
        
        alert = UIAlertController(title: NSLocalizedString("reportPost", comment: ""), message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = NSLocalizedString("writeTheReason", comment: "")
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("report", comment: ""), style: .destructive, handler: { _ in
            let reportReason = alert.textFields?.first?.text ?? "report"
            
            let reportDTO = ReportDTO(reportedContentId: post.id, reportedUserId: post.user.id, content: reportReason, reportType: .post)
            self.postViewModel.reportPost(token: self.viewModel.validateToken(), reportDTO: reportDTO)
        }))
        
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
            sheet.delegate = self
        }
        
        self.present(sheetViewController, animated: true, completion: nil)
    }
}

extension UserPostViewController: AddPostViewControllerDelegate {
    func showToastMessage(_ message: String) {
        //showToast(view, message: message)
    }
    
    func didCreatePost() {
        postViewModel.fetchPosts()
    }
}

extension UserPostViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.loadPosts()
    }
}
