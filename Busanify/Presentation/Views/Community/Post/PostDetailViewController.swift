//
//  PostDetailViewController.swift
//  Busanify
//
//  Created by 장예진 on 9/25/24.
//

import UIKit
import Kingfisher
import Combine

class PostDetailViewController: UIViewController {
    private let post: Post
    private let commentViewModel: CommentViewModel
    private let postViewModel: PostViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let authViewModel = AuthenticationViewModel.shared
    private let keyChain = Keychain()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInset = .zero
        tableView.backgroundColor = .systemGray5
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private lazy var dividerLine: UIView = {
        let dividerLine = UIView()
        dividerLine.backgroundColor = .systemGray5
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        return dividerLine
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        return imageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 200, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        return collectionView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.textColor = .gray
        return label
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    init(post: Post, commentViewModel: CommentViewModel, postViewModel: PostViewModel) {
        self.post = post
        self.commentViewModel = commentViewModel
        self.postViewModel = postViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        configureUI()
        fetchComments()
    }

    private func setupUI() {
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(dateLabel)
        view.addSubview(moreButton)
        view.addSubview(contentLabel)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        view.addSubview(dividerLine)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            
            usernameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 8),
            dateLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            moreButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            moreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            
            dividerLine.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            dividerLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dividerLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dividerLine.heightAnchor.constraint(equalToConstant: 1),
            
            tableView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
    }

    private func configureUI() {
        if let profileImage = post.user.profileImage {
            let url = URL(string: profileImage)
            profileImageView.kf.setImage(with: url)
        }
        usernameLabel.text = post.user.nickname
        contentLabel.text = post.content
        dateLabel.text = post.createdAt
        
        setupMoreButton()
        
        collectionView.reloadData()
    }
    
    private func setupMoreButton() {
        var menuItems: [UIAction] = [
            UIAction(title: NSLocalizedString("report", comment: ""), image: UIImage(systemName: "exclamationmark.triangle"), handler: { [weak self] _ in
                self?.reportPost()
            })
        ]
        
        switch authViewModel.state {
        case .googleSignedIn(let user):
            if post.user.id == user.userID {
                menuItems = [
                    UIAction(title: NSLocalizedString("edit", comment: ""), image: UIImage(systemName: "pencil"), handler: { [weak self] _ in
                        self?.updatePost()
                    }),
                    UIAction(title: NSLocalizedString("delete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                        self?.showDeleteConfirmationAlert()
                    })
                ]
            }
        case .appleSignedIn:
            guard let userId = self.keyChain.read(key: "appleUserId") else {
                print("No valid user ID")
                return
            }
            
            if post.user.id == userId {
                menuItems = [
                    UIAction(title: NSLocalizedString("edit", comment: ""), image: UIImage(systemName: "pencil"), handler: { [weak self] _ in
                        self?.updatePost()
                    }),
                    UIAction(title: NSLocalizedString("delete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                        self?.showDeleteConfirmationAlert()
                    })
                ]
            }
        default:
            break
        }
        
        moreButton.menu = UIMenu(children: menuItems)
    }

    private func fetchComments() {
        commentViewModel.fetchComments(postId: post.id)
        commentViewModel.$comments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }.store(in: &cancellables)
    }
}

extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentViewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
            return UITableViewCell()
        }
        
        let comment = commentViewModel.comments[indexPath.row]
        cell.configure(comment: comment, post: post)
        cell.delegate = self
        return cell
    }
}

extension PostDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.photoUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        // 기존의 이미지 뷰 제거 (중복 추가 방지)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // 이미지 뷰 생성 및 추가
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        // 이미지 설정
        if let url = URL(string: post.photoUrls[indexPath.item]) {
            imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "circle.dotted"))
        } else {
            imageView.image = UIImage(systemName: "circle.dotted")
        }
        
        // 이미지 뷰를 셀에 추가
        cell.contentView.addSubview(imageView)
        
        return cell
    }
}

// Post 관련 로직을 처리하는 확장
extension PostDetailViewController{
    
    // 게시글 수정
    func updatePost() {
        let updatePostVC = UpdatePostViewController(postViewModel: postViewModel, post: post)
        updatePostVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(updatePostVC, animated: true)
    }

    // 게시글 삭제
    func showDeleteConfirmationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("deletePost", comment: ""), message: NSLocalizedString("postWillBeDeleted", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: NSLocalizedString("delete", comment: ""), style: .destructive) { [weak self] _ in
            self?.deletePost()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func deletePost() {
        Task {
            do {
                try await postViewModel.deletePost(token: authViewModel.getToken()!, id: post.id, photoUrls: post.photoUrls)
                navigationController?.popViewController(animated: true)
            } catch {
                print("게시글 삭제 실패: \(error)")
            }
        }
    }

    // 게시글 신고
    func reportPost() {
        var alert = UIAlertController()
        
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            alert = UIAlertController(title: NSLocalizedString("reportPost", comment: ""), message: nil, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("writeTheReason", comment: "")
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            let reportAction = UIAlertAction(title: NSLocalizedString("report", comment: ""), style: .destructive) { _ in
                guard let reason = alert.textFields?.first?.text, !reason.isEmpty else { return }
                
                let reportDTO = ReportDTO(reportedContentId: self.post.id, reportedUserId: self.post.user.id, content: reason, reportType: .post)
                self.postViewModel.reportPost(token: self.authViewModel.getToken()!, reportDTO: reportDTO)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(reportAction)
        case .signedOut:
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForReport", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func moveToSignInView() {
        let signInVC = SignInViewController()
        present(signInVC, animated: true, completion: nil)
    }
}

// 댓글 신고 및 삭제 로직
extension PostDetailViewController: CommentTableViewCellDelegate {
    func didDeleteComment(_ comment: Comment) {
        Task {
            do {
                if let index = commentViewModel.comments.firstIndex(where: { $0.id == comment.id }) {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    commentViewModel.comments.remove(at: index)
                    tableView.endUpdates()
                }
                try await commentViewModel.deleteComment(token: authViewModel.getToken()!, id: comment.id)
            } catch {
                print("댓글 삭제 실패: \(error)")
            }
        }
    }
    
    func reportComment(_ comment: Comment) {
        var alert = UIAlertController()
        
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            alert = UIAlertController(title: NSLocalizedString("reportComment", comment: ""), message: nil, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = NSLocalizedString("writeTheReason", comment: "")
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            let reportAction = UIAlertAction(title: NSLocalizedString("report", comment: ""), style: .destructive) { _ in
                guard let reason = alert.textFields?.first?.text, !reason.isEmpty else { return }
                
                let reportDTO = ReportDTO(reportedContentId: comment.id, reportedUserId: comment.user.id, content: reason, reportType: .comment)
                self.commentViewModel.reportComment(token: self.authViewModel.getToken()!, reportDTO: reportDTO)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(reportAction)
        case .signedOut:
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForReport", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
}
