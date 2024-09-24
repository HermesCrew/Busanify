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
        textField.placeholder = "Add Comments"
        textField.delegate = self
        
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.isEnabled = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.addComment()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var contentTextFieldBottomConstraint: NSLayoutConstraint = {
       return contentTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    }()
    
    init(commentViewModel: CommentViewModel, post: Post) {
        self.commentViewModel = commentViewModel
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
        
        commentViewModel.fetchComments(postId: post.id)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(profileImageView)
        view.addSubview(contentTextField)
        view.addSubview(saveButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        contentTextField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            contentTextFieldBottomConstraint,
            
            saveButton.trailingAnchor.constraint(equalTo: contentTextField.trailingAnchor, constant: -8),
            saveButton.centerYAnchor.constraint(equalTo: contentTextField.centerYAnchor),
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
                commentViewModel.fetchComments(postId: post.id)
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
        cell.configure(with: commentViewModel.comments[indexPath.item])
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
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
            } catch {
                print("Failed to delete review: \(error)")
            }
        }
    }
    
    func reportComment(_ comment: Comment) {
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
                
                let reportDTO = ReportDTO(reportedContentId: comment.id, reportedUserId: comment.user.id, content: reportReason, reportType: .comment)
                self.commentViewModel.reportComment(token: self.authViewModel.getToken()!, reportDTO: reportDTO)
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

extension CommentViewController: UITextFieldDelegate, UIGestureRecognizerDelegate {
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
