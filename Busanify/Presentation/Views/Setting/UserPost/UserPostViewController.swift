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
    private let authViewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        enableInteractivePopGesture()
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
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
    func blockUserByPost(_ post: Post) {
        var alert = UIAlertController()
        
        alert = UIAlertController(title: NSLocalizedString("blockPost", comment: ""), message: nil, preferredStyle: .alert)
        

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { [weak self] _ in
            Task {
                do {
                    if let token = self?.authViewModel.getToken() {
                        try await self?.postViewModel.blockUserByPost(token: token, blockedUserId: post.user.id)
                        // 게시글 목록 갱신
                        self?.postViewModel.fetchPosts(token: token)
                    }
                } catch {
                    print("Error blocking user or fetching posts: \(error)")
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showPostDetail(post: Post) {
        let commentViewModel = CommentViewModel(useCase: CommentApi())
        let postViewModel = PostViewModel(useCase: PostApi())
        
        let postDetailVC = PostDetailViewController(post: post, commentViewModel: commentViewModel, postViewModel: postViewModel)
        postDetailVC.hidesBottomBarWhenPushed = true
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
        
        alert = UIAlertController(title: NSLocalizedString("reportContent", comment: ""), message: NSLocalizedString("reportContentMessage", comment: ""), preferredStyle: .actionSheet)
        
        // 각 신고 사유에 대한 선택지를 추가
        alert.addAction(UIAlertAction(title: NSLocalizedString("misinformation", comment: ""), style: .default, handler: { _ in
            self.handleReportReason(post: post, reason: "misinformation")
            self.showReportConfirmationAlert()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("advertisement", comment: ""), style: .default, handler: { _ in
            self.handleReportReason(post: post, reason: "advertisement")
            self.showReportConfirmationAlert()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("pornography", comment: ""), style: .default, handler: { _ in
            self.handleReportReason(post: post, reason: "pornography")
            self.showReportConfirmationAlert()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("violence", comment: ""), style: .default, handler: { _ in
            self.handleReportReason(post: post, reason: "violence")
            self.showReportConfirmationAlert()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("other", comment: ""), style: .default, handler: { _ in
            self.handleReportReason(post: post, reason: "other")
            self.showReportConfirmationAlert()
        }))

        // 취소 버튼 추가
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleReportReason(post: Post, reason: String) {
        let reportDTO = ReportDTO(reportedContentId: post.id, reportedUserId: post.user.id, content: reason, reportType: .post)
        self.postViewModel.reportPost(token: self.viewModel.validateToken(), reportDTO: reportDTO)
    }
    
    func showReportConfirmationAlert() {
        let confirmationAlert = UIAlertController(title: NSLocalizedString("reportSubmitted", comment: ""), message: NSLocalizedString("reportSubmittedMessage", comment: ""), preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK"), style: .default, handler: nil))
        
        self.present(confirmationAlert, animated: true, completion: nil)
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
        showToast(view, message: message)
    }
    
    func didCreatePost() {
        postViewModel.fetchPosts(token: authViewModel.getToken())
    }
}

extension UserPostViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.loadPosts()
    }
}
