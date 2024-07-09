//
//  MainViewController.swift
//  Busanify
//
//  Created by 이인호 on 6/27/24.
//
// 임시로 로그인 잘 되는지 확인하기 위한 VC

import UIKit
import Combine

class MainViewController: UIViewController {
    private let viewModel: AuthenticationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        updateView()
        bind()
    }
    
    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateView()
            }
            .store(in: &cancellables)
    }
    
    private func updateView() {
        children.forEach { $0.removeFromParent() }
        
        switch viewModel.state {
        case .loading:
            let loadingViewController = LoadingViewController()
            addChild(loadingViewController)
            loadingViewController.view.frame = view.bounds
            view.addSubview(loadingViewController.view)
            loadingViewController.didMove(toParent: self)
            
        case .signedIn:
            let profileViewController = UserProfileViewController(viewModel: viewModel)
            addChild(profileViewController)
            profileViewController.view.frame = view.bounds
            view.addSubview(profileViewController.view)
            profileViewController.didMove(toParent: self)
            navigationItem.title = NSLocalizedString("User Profile", comment: "User profile navigation title")
            
        case .signedOut:
            let signInViewController = SignInViewController(viewModel: viewModel)
            addChild(signInViewController)
            signInViewController.view.frame = view.bounds
            view.addSubview(signInViewController.view)
            signInViewController.didMove(toParent: self)
            navigationItem.title = NSLocalizedString("Sign In", comment: "Sign-in navigation title")
        }
    }
}
