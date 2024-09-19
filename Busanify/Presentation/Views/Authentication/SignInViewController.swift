//
//  SignInViewController.swift
//  Busanify
//
//  Created by 이인호 on 6/26/24.
//

import UIKit
import GoogleSignIn
import AuthenticationServices

class SignInViewController: UIViewController {
    
    private let viewModel = AuthenticationViewModel.shared
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "BUSANIFY"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    private lazy var googleSignInButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        
        configuration.image = UIImage(named: "google_logo")
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        button.configuration = configuration
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle("Sign in with Google", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .clear
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.viewModel.googleSignIn { success in
                if success {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var appleSignInButton: UIButton = {
        let button = UIButton()
        
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(named: "apple_logo")
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        button.configuration = configuration
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle("Sign in with Apple", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .clear
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.appleSignIn()
        }, for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView(arrangedSubviews: [googleSignInButton, appleSignInButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        view.addSubview(titleLabel)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func appleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        //로그인 성공
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // You can create an account in your system.
            let userIdentifier = appleIDCredential.user
            
            if let authorizationCode = appleIDCredential.authorizationCode,
                let authCodeString = String(data: authorizationCode, encoding: .utf8) {
                self.viewModel.appleSignIn(code: authCodeString, userId: userIdentifier) { success in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 로그인 실패(유저의 취소도 포함)
        print("login failed - \(error.localizedDescription)")
    }
}
