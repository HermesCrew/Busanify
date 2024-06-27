//
//  SignInViewController.swift
//  Busanify
//
//  Created by 이인호 on 6/26/24.
//

import UIKit
import GoogleSignIn

class SignInViewController: UIViewController {
    
    private lazy var signInButton : GIDSignInButton = {
        let signInButton = GIDSignInButton()
        signInButton.style = .wide
        signInButton.colorScheme = .dark
        
        return signInButton
    }()
    
    private let viewModel: AuthenticationViewModel
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        signInButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.signIn()
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(signInButton)
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

