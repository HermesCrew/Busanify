//
//  SettingViewController.swift
//  Busanify
//
//  Created by 이인호 on 7/9/24.
//

import UIKit
import Combine
import PhotosUI
import Kingfisher

class SettingViewController: UIViewController {
    private let viewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    var data: Data?
    var isNicknameEditing = false
    
    private lazy var loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Login"
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .black
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var cameraIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.contentMode = .center
        imageView.tintColor = .gray
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let nameLabel = UILabel()
//        nameLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        
        return nameLabel
    }()
    
    lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.autocapitalizationType = .none
        textField.isHidden = true
        textField.delegate = self
        
        return textField
    }()
    
    private lazy var editNicknameButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "pencil")
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(editNickname), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var emailLabel: UILabel = {
        let emailLabel = UILabel()
        emailLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        emailLabel.textColor = .gray
        
        return emailLabel
    }()
    
    private lazy var settingTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        return tableView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let footerView = UIView()
    
    private lazy var footerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        button.addAction(UIAction { [weak self] _ in
            self?.showDeleteAccountAlert()
        }, for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureProfile()
        addGestureRecognizer()
        
        bind()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(loginButton)
        view.addSubview(profileImageView)
        view.addSubview(nicknameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(editNicknameButton)
        view.addSubview(emailLabel)
        view.addSubview(settingTableView)
        footerView.addSubview(footerButton)
        settingTableView.tableFooterView = footerView
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        editNicknameButton.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        settingTableView.translatesAutoresizingMaskIntoConstraints = false
        footerButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cameraIconView)
        cameraIconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            cameraIconView.widthAnchor.constraint(equalToConstant: 30),   // 카메라 아이콘 크기 설정
            cameraIconView.heightAnchor.constraint(equalToConstant: 30),
            cameraIconView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -5), // 오른쪽 하단에 위치
            cameraIconView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -5),
            
            nicknameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nicknameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nicknameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameTextField.centerYAnchor.constraint(equalTo: nicknameLabel.centerYAnchor),
            
            editNicknameButton.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor, constant: 14),
            editNicknameButton.centerYAnchor.constraint(equalTo: nicknameLabel.centerYAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            settingTableView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 40),
            settingTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            footerButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureProfile() {
        switch viewModel.state {
        case .googleSignedIn, .appleSignedIn:
            setProfileElementsHidden(false)
            
            if let currentUser = viewModel.currentUser {
                if let profileImage = currentUser.profileImage {
                    let url = URL(string: profileImage)
                    profileImageView.kf.setImage(
                        with: url,
                        placeholder: profileImageView.image)
                } else {
                    profileImageView.image = UIImage(systemName: "person.fill")
                }
                nicknameLabel.text = currentUser.nickname
                emailLabel.text = currentUser.email
            }
        case .signedOut:
            setProfileElementsHidden(true)
        }
    }
    
    private func setProfileElementsHidden(_ isHidden: Bool) {
        profileImageView.isHidden = isHidden
        cameraIconView.isHidden = isHidden
        nicknameLabel.isHidden = isHidden
        editNicknameButton.isHidden = isHidden
        emailLabel.isHidden = isHidden
        footerButton.isHidden = isHidden
        loginButton.isHidden = !isHidden
    }
    
    private func bind() {
        viewModel.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                self?.configureProfile()
                self?.settingTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureProfile()
                self?.settingTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func editNickname() {
        self.isNicknameEditing.toggle()
        if isNicknameEditing {
            nicknameLabel.isHidden = true
            nicknameTextField.isHidden = false
            nicknameTextField.text = nicknameLabel.text
            nicknameTextField.becomeFirstResponder()
            editNicknameButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        } else {
            nicknameLabel.isHidden = false
            nicknameTextField.isHidden = true
            
            if let newName = nicknameTextField.text, !newName.isEmpty, nicknameTextField.text != nicknameLabel.text {
                self.viewModel.updateProfileNickname(nickname: newName) { [weak self] success in
                    if success {
                        DispatchQueue.main.async {
                            self?.nicknameLabel.text = newName
                        }
                    }
                }
            }
            editNicknameButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
    }
    
    @objc private func goToLogin() {
        let signInVC = SignInViewController()
        present(signInVC, animated: true)
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(title: "Busanify", message: "Logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { [weak self] _ in
            switch self?.viewModel.state {
            case .googleSignedIn:
                self?.viewModel.googleSignOut()
            case .appleSignedIn:
                self?.viewModel.appleSignOut()
            default:
                break
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func showDeleteAccountAlert() {
        let alert = UIAlertController(title: "Busanify", message: "Are you sure you want to delete your account? All data will be removed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.deleteUser()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func addGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(addProfileImageButtonTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(profileImageTapGesture)
    }
    
    @objc private func addProfileImageButtonTapped(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Add Profile Image", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Select Image", style: .default, handler: { _ in
            self.presentPHPPicker()
        }))
        
        if let currentUser = viewModel.currentUser, currentUser.profileImage != nil {
            actionSheet.addAction(UIAlertAction(title: "Delete exist Image", style: .destructive, handler: { _ in
                self.loadingIndicator.startAnimating()
                self.viewModel.deleteProfileImage { success in
                    if success {
                        self.loadingIndicator.stopAnimating()
                    }
                }
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.state == .signedOut ? 5 : 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingInfos =  [("My Review", "doc.text.magnifyingglass"), ("My Community Post", "square.and.pencil"), ("Language", "globe"), ("Privacy Policy", "shield.lefthalf.fill"), ("Version", "info.circle"), ("Logout", "rectangle.portrait.and.arrow.right")]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else {
            return UITableViewCell()
        }
        
        let settingInfo = settingInfos[indexPath.row]
        cell.configure(with: settingInfo)
        cell.selectionStyle = .none
            
        switch indexPath.row {
        case 0, 1, 2, 3:
            cell.accessoryType = .disclosureIndicator
        default:
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            showLogoutAlert()
        }
    }
}

extension SettingViewController: PHPickerViewControllerDelegate {
    @objc private func presentPHPPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider else { return }
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.data = data
                        self.loadingIndicator.startAnimating()
                        self.viewModel.updateProfileImage(data: data) { success in
                            if success {
                                // 프로필 수정 완료되었습니다 알림 표시
                                self.loadingIndicator.stopAnimating()
                            }
                        }
                    }
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
}

extension SettingViewController: UITextFieldDelegate {
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // Return 키를 눌렀을 때 키보드 내리기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
