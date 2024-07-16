//
//  UserProfileViewController.swift
//  Busanify
//
//  Created by 이인호 on 6/27/24.
//

import UIKit
import GoogleSignIn
import Combine

class UserProfileViewController: UIViewController {
    
    private let viewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        
        return nameLabel
    }()
    
    private lazy var emailLabel: UILabel = {
        let emailLabel = UILabel()
        emailLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        return emailLabel
    }()
    
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("logout", for: .normal)
        return logoutButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureProfile()
        
        logoutButton.addAction(UIAction { [weak self] _ in
            switch self?.viewModel.state {
            case .googleSignedIn:
                self?.viewModel.googleSignOut()
            case .appleSignedIn:
                self?.viewModel.appleSignOut()
            default:
                break
            }
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(logoutButton)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            logoutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureProfile() {
        switch viewModel.state {
        case .googleSignedIn:
            if let userProfile = viewModel.currentUser?.profile {
                nameLabel.text = userProfile.name
                emailLabel.text = userProfile.email
            }
        case .appleSignedIn:
            if let userProfile = viewModel.appleUserProfile {
                nameLabel.text = userProfile.name
                emailLabel.text = userProfile.email
            }
        default:
            break
        }
    }
}
