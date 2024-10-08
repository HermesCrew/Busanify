//
//  CommentViewController.swift
//  Busanify
//
//  Created by 이인호 on 9/23/24.
//

import UIKit
import Combine

class CommentViewController: UIViewController {
    
    private let commentViewModel: CommentViewModel
    private let postViewModel: PostViewModel
    private let authViewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private let post: Post
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        
        return imageView
    }()
    
    private lazy var contentTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.autocapitalizationType = .none
        textField.placeholder = NSLocalizedString("addComment", comment: "")
        textField.delegate = self
        
        return textField
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        
        label.text = NSLocalizedString("inappropriate", comment: "")
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .gray
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "paperplane.fill")
        config.baseForegroundColor = .systemBlue
        config.buttonSize = .small
        
        let button = UIButton(configuration: config)
        button.isEnabled = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.addComment()
            self?.dismissKeyboard()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var contentTextFieldBottomConstraint: NSLayoutConstraint = {
       return warningLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    }()
    
    init(commentViewModel: CommentViewModel, postViewModel: PostViewModel, post: Post) {
        self.commentViewModel = commentViewModel
        self.postViewModel = postViewModel
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configure()
        bind()
        setupTapGesture()
        setupKeyboardEvent()
        
        commentViewModel.fetchComments(postId: post.id, token: authViewModel.getToken())
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(profileImageView)
        view.addSubview(contentTextField)
        view.addSubview(saveButton)
        view.addSubview(warningLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        contentTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentTextField.topAnchor),
            
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentTextField.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            
            contentTextField.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            contentTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            saveButton.trailingAnchor.constraint(equalTo: contentTextField.trailingAnchor),
            saveButton.centerYAnchor.constraint(equalTo: contentTextField.centerYAnchor),
            
            warningLabel.leadingAnchor.constraint(equalTo: contentTextField.leadingAnchor),
            warningLabel.trailingAnchor.constraint(equalTo: contentTextField.trailingAnchor),
            warningLabel.topAnchor.constraint(equalTo: contentTextField.bottomAnchor, constant: 2),
            contentTextFieldBottomConstraint,
        ])
    }
    
    private func configure() {
        if let profileImage = authViewModel.currentUser?.profileImage {
            let url = URL(string: profileImage)
            profileImageView.kf.setImage(with: url)
        }
    }
    
    private func bind() {
        commentViewModel.$comments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comments in
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
    
    private func addComment() {
        Task {
            do {
                try await commentViewModel.createComment(token: authViewModel.getToken(), postId: post.id, content: contentTextField.text ?? "")
                commentViewModel.fetchComments(postId: post.id, token: authViewModel.getToken())
                postViewModel.fetchPosts(token: authViewModel.getToken())
                contentTextField.text = ""
                saveButton.isEnabled = false
            } catch {
                print("Failed to create post: \(error)")
            }
        }
    }
    
    private func moveToSignInView() {
        let signInVC = SignInViewController()
        present(signInVC, animated: true, completion: nil)
    }
    
    func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        commentViewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(comment: commentViewModel.comments[indexPath.item], post: post)
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
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
                            self.commentViewModel.fetchComments(postId: self.post.id, token: self.authViewModel.getToken())
                            self.postViewModel.fetchPosts(token:  self.authViewModel.getToken())
                            
                            if self.post.user.id == comment.user.id {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } catch {
                        print("Error blocking user or fetching posts: \(error)")
                    }
                }
            }))
        case .signedOut:
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForBlock", comment: ""), preferredStyle: .alert)
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
                if let index = self.commentViewModel.comments.firstIndex(where: { $0.id == comment.id }) {
                    tableView.beginUpdates()
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    commentViewModel.comments.remove(at: index)
                    tableView.endUpdates()
                }
                try await commentViewModel.deleteComment(token: self.authViewModel.getToken()!, id: comment.id)
                postViewModel.fetchPosts(token: self.authViewModel.getToken())
            } catch {
                print("Failed to delete review: \(error)")
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
    
    func showReportConfirmationAlert() {
        let confirmationAlert = UIAlertController(title: NSLocalizedString("reportSubmitted", comment: ""), message: NSLocalizedString("reportSubmittedMessage", comment: ""), preferredStyle: .alert)
        
        confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK"), style: .default, handler: nil))
        
        self.present(confirmationAlert, animated: true, completion: nil)
    }
}

extension CommentViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if authViewModel.state == .signedOut {
            var alert = UIAlertController()
            alert = UIAlertController(title: NSLocalizedString("needLogin", comment: ""), message: NSLocalizedString("needLoginMessageForWriteComment", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("login", comment: ""), style: .default, handler: { [weak self] _ in
                self?.moveToSignInView()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?) ?? ""
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        saveButton.isEnabled = !updatedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return true
    }
    
    // MARK: - Keyboard Handling
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 터치된 뷰가 버튼일 경우 tapGesture를 무시하도록 설정
        if touch.view is UIButton {
            return false // 버튼을 터치한 경우 제스처가 실행되지 않도록 함
        }
        return true
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // Return 키를 눌렀을 때 키보드 내리기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 키보드 올라왔을때
    @objc func keyboardWillShow(_ sender: Notification) {
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        contentTextFieldBottomConstraint.constant = -(keyboardHeight - view.safeAreaInsets.bottom + 16)
        view.layoutIfNeeded()
    }
    
    // 키보드 내려갔을때
    @objc func keyboardWillHide(_ sender: Notification) {
        contentTextFieldBottomConstraint.constant = 0
        view.layoutIfNeeded()
    }
}
