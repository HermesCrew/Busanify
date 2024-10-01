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
    private var post: Post
    private let commentViewModel: CommentViewModel
    private let postViewModel: PostViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let authViewModel = AuthenticationViewModel.shared
    private let keyChain = Keychain()
    
    weak var delegate: AddPostViewControllerDelegate?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInset = .zero
        tableView.backgroundColor = .white
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
        imageView.image = UIImage(systemName: "person.crop.circle")
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
        collectionView.backgroundColor = .clear
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
        setupNavigationBar()
        enableInteractivePopGesture()
        fetchComments()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupUI() {
            view.addSubview(tableView)
            tableView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
            tableView.tableHeaderView = createTableHeaderView()
        }

    private func createTableHeaderView() -> UIView {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 350)

        headerView.addSubview(profileImageView)
        headerView.addSubview(usernameLabel)
        headerView.addSubview(dateLabel)
        headerView.addSubview(moreButton)
        headerView.addSubview(contentLabel)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            
            usernameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 8),
            dateLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            moreButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            moreButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            moreButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
        ])

        contentLabel.preferredMaxLayoutWidth = view.frame.width - 32 // 좌우 패딩고려
        
        if !post.photoUrls.isEmpty {
            headerView.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 16),
                collectionView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                collectionView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                collectionView.heightAnchor.constraint(equalToConstant: 200),
                collectionView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
            ])
        } else {
            contentLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16).isActive = true
        }

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame.size.height = height

        return headerView
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
        
        if !post.photoUrls.isEmpty {
            if collectionView.superview == nil {
                tableView.tableHeaderView?.addSubview(collectionView)
                collectionView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    collectionView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 16),
                    collectionView.leadingAnchor.constraint(equalTo: tableView.tableHeaderView!.leadingAnchor, constant: 16),
                    collectionView.trailingAnchor.constraint(equalTo: tableView.tableHeaderView!.trailingAnchor, constant: -16),
                    collectionView.heightAnchor.constraint(equalToConstant: 200),
                    collectionView.bottomAnchor.constraint(equalTo: tableView.tableHeaderView!.bottomAnchor, constant: -16)
                ])
            }
            collectionView.isHidden = false
            collectionView.reloadData()
        } else {
            collectionView.isHidden = true
            contentLabel.bottomAnchor.constraint(equalTo: tableView.tableHeaderView!.bottomAnchor, constant: -16).isActive = true
        }
        
        updateTableHeaderViewHeight()
    }
    
    private func updateTableHeaderViewHeight() {
        guard let headerView = tableView.tableHeaderView else { return }
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
    }
    
    private func setupMoreButton() {
        var menuItems: [UIAction] = [
            UIAction(title: NSLocalizedString("report", comment: ""), image: UIImage(systemName: "exclamationmark.triangle"), handler: { [weak self] _ in
                self?.reportPost()
            }),
            UIAction(title: NSLocalizedString("Block", comment: ""), image: UIImage(systemName: "nosign"), attributes: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                self.blockUserByPost(self.post)
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
        commentViewModel.fetchComments(postId: post.id, token: authViewModel.getToken())
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
        cell.selectionStyle = .none
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
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
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
    
    // 이미지를 선택했을 때,, 사진 크게보기
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imagePreviewVC = ImagePreviewViewController(imageUrls: post.photoUrls) // 모든 이미지 전달하도록 수정
        imagePreviewVC.modalPresentationStyle = .overFullScreen
        present(imagePreviewVC, animated: true, completion: nil)
    }
}

// Post 관련 로직을 처리하는 확장
extension PostDetailViewController: UpdatePostViewControllerDelegate {
    func blockUserByPost(_ post: Post) {
        var alert = UIAlertController()
        
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            alert = UIAlertController(title: NSLocalizedString("blockPost", comment: ""), message: nil, preferredStyle: .alert)
            

            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { [weak self] _ in
                Task {
                    do {
                        if let token = self?.authViewModel.getToken() {
                            try await self?.postViewModel.blockUserByPost(token: token, blockedUserId: post.user.id)
                            // 게시글 목록 갱신
                            self?.navigationController?.popViewController(animated: true)
                        }
                    } catch {
                        print("Error blocking user or fetching posts: \(error)")
                    }
                }
            }))
        case .signedOut:
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForReport", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func showToastMessage(messaage: String) {
        self.showToast(view, message: messaage)
    }
    
    func didUpdatePost(post: Post) {
        delegate?.didCreatePost()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let hadPhotos = !self.post.photoUrls.isEmpty
            self.post = post
            let hasPhotosNow = !post.photoUrls.isEmpty
            
            if !hadPhotos && hasPhotosNow {
                // 사진이 새로 추가된 경우
                self.tableView.tableHeaderView = self.createTableHeaderView()
            }
            
            self.configureUI()
            self.tableView.reloadData()
            
            if hasPhotosNow {
                self.collectionView.reloadData()
            }
            
            self.updateTableHeaderViewHeight()
        }
    }
    // 게시글 수정
    func updatePost() {
        let updatePostVC = UpdatePostViewController(postViewModel: postViewModel, post: post)
        updatePostVC.updateDelegate = self
        updatePostVC.hidesBottomBarWhenPushed = true
        updatePostVC.delegate = self
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
                self.delegate?.didCreatePost()
                self.delegate?.showToastMessage("게시글이 삭제되었습니다.")
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
            alert = UIAlertController(title: NSLocalizedString("reportContent", comment: ""), message: NSLocalizedString("reportContentMessage", comment: ""), preferredStyle: .actionSheet)
            
            // 각 신고 사유에 대한 선택지를 추가
            alert.addAction(UIAlertAction(title: NSLocalizedString("misinformation", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(post: self.post, reason: "misinformation")
                self.showReportConfirmationAlert()
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("advertisement", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(post: self.post, reason: "advertisement")
                self.showReportConfirmationAlert()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("pornography", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(post: self.post, reason: "pornography")
                self.showReportConfirmationAlert()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("violence", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(post: self.post, reason: "violence")
                self.showReportConfirmationAlert()
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("other", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(post: self.post, reason: "other")
                self.showReportConfirmationAlert()
            }))

            // 취소 버튼 추가
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        case .signedOut:
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForReport", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleReportReason(post: Post, reason: String) {
        let reportDTO = ReportDTO(reportedContentId: post.id, reportedUserId: post.user.id, content: reason, reportType: .post)
        self.postViewModel.reportPost(token: self.authViewModel.getToken()!, reportDTO: reportDTO)
    }
    
    func showReportConfirmationAlert() {
        let confirmationAlert = UIAlertController(title: NSLocalizedString("reportSubmitted", comment: ""), message: NSLocalizedString("reportSubmittedMessage", comment: ""), preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK"), style: .default, handler: nil))
        
        self.present(confirmationAlert, animated: true, completion: nil)
    }
    
    private func moveToSignInView() {
        let signInVC = SignInViewController()
        present(signInVC, animated: true, completion: nil)
    }
}

// 댓글 신고 및 삭제 로직
extension PostDetailViewController: CommentTableViewCellDelegate {
    func blockUserByComment(_ comment: Comment) {
        var alert = UIAlertController()
        
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            alert = UIAlertController(title: NSLocalizedString("blockPost", comment: ""), message: nil, preferredStyle: .alert)
            

            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                
                Task {
                    do {
                        if let token = self.authViewModel.getToken() {
                            try await self.commentViewModel.blockUserByComment(token: token, blockedUserId: comment.user.id)
                            // 게시글 목록 갱신
                            self.navigationController?.popViewController(animated: true)
                        }
                    } catch {
                        print("Error blocking user or fetching posts: \(error)")
                    }
                }
            }))
        case .signedOut:
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForReport", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
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
                self.delegate?.didCreatePost()
            } catch {
                print("댓글 삭제 실패: \(error)")
            }
        }
    }
    
    func reportComment(_ comment: Comment) {
        var alert = UIAlertController()
        
        switch authViewModel.state {
        case .googleSignedIn, .appleSignedIn:
            alert = UIAlertController(title: NSLocalizedString("reportContent", comment: ""), message: NSLocalizedString("reportContentMessage", comment: ""), preferredStyle: .actionSheet)
            
            // 각 신고 사유에 대한 선택지를 추가
            alert.addAction(UIAlertAction(title: NSLocalizedString("misinformation", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(comment: comment, reason: "misinformation")
                self.showReportConfirmationAlert()
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("advertisement", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(comment: comment, reason: "advertisement")
                self.showReportConfirmationAlert()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("pornography", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(comment: comment, reason: "pornography")
                self.showReportConfirmationAlert()
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("violence", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(comment: comment, reason: "violence")
                self.showReportConfirmationAlert()
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("other", comment: ""), style: .default, handler: { _ in
                self.handleReportReason(comment: comment, reason: "other")
                self.showReportConfirmationAlert()
            }))

            // 취소 버튼 추가
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        case .signedOut:
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForReport", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleReportReason(comment: Comment, reason: String) {
        let reportDTO = ReportDTO(reportedContentId: comment.id, reportedUserId: comment.user.id, content: reason, reportType: .comment)
        self.commentViewModel.reportComment(token: self.authViewModel.getToken()!, reportDTO: reportDTO)
    }
}

extension PostDetailViewController: AddPostViewControllerDelegate {
    func didCreatePost() {
        //
    }
    
    func showToastMessage(_ message: String) {
        showToast(view, message: message)
    }
}
