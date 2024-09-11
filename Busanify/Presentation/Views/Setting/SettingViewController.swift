//
//  SettingViewController.swift
//  Busanify
//
//  Created by 이인호 on 7/9/24.
//

import UIKit
import Combine
import PhotosUI

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    var data: Data?
    var isNicknameEditing = false
    
    private lazy var loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "로그인"
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3).cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.cornerRadius = 60
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
        textField.isHidden = true
        
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
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameTextField.translatesAutoresizingMaskIntoConstraints = false
        editNicknameButton.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        settingTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nicknameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nicknameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nicknameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nicknameTextField.centerYAnchor.constraint(equalTo: nicknameLabel.centerYAnchor),
            
            editNicknameButton.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor),
            editNicknameButton.centerYAnchor.constraint(equalTo: nicknameLabel.centerYAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            settingTableView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 40),
            settingTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureProfile() {
        switch viewModel.state {
        case .googleSignedIn, .appleSignedIn:
            setProfileElementsHidden(false)
            
            if let currentUser = viewModel.currentUser {
                profileImageView.image = UIImage(data: currentUser.profileImage)
                nicknameLabel.text = currentUser.nickname
                emailLabel.text = currentUser.email
            }
        case .signedOut:
            setProfileElementsHidden(true)
        }
    }
    
    private func setProfileElementsHidden(_ isHidden: Bool) {
        profileImageView.isHidden = isHidden
        nicknameLabel.isHidden = isHidden
        editNicknameButton.isHidden = isHidden
        emailLabel.isHidden = isHidden
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.state == .signedOut ? 5 : 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingInfos =  [("My Review", "doc.text.magnifyingglass"), ("My Community Post", "square.and.pencil"), ("Language", "globe"), ("Version", "info.circle"), ("Privacy Policy", "shield.lefthalf.fill"), ("Logout", "rectangle.portrait.and.arrow.right")]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell else {
            return UITableViewCell()
        }
        
        let settingInfo = settingInfos[indexPath.row]
        cell.configure(with: settingInfo)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            showLogoutAlert()
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
}

extension SettingViewController: PHPickerViewControllerDelegate {
    
    private func addGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPHPPicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
    }
    
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
                        self.viewModel.updateProfileImage(data: data) { success in
                            if success {
                                // 프로필 수정 완료되었습니다 알림 표시
                            }
                        }
                    }
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
            }
            
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let image = image as? UIImage else { return }
                
                DispatchQueue.main.async {
                    self?.profileImageView.contentMode = .scaleAspectFill
                    self?.profileImageView.image = image
                }
            }
        }
    }
}
