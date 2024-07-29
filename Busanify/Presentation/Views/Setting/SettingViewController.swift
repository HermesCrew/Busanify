//
//  SettingViewController.swift
//  Busanify
//
//  Created by 이인호 on 7/9/24.
//

import UIKit
import Combine

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel = AuthenticationViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var goToLoginView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "userCell")
        
        return tableView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind()
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(goToLoginView)
        
        goToLoginView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            goToLoginView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            goToLoginView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            goToLoginView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            goToLoginView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    
    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.goToLoginView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        switch viewModel.state {
        case .googleSignedIn(let user):
            if let userProfile = user.profile {
                content.text = userProfile.name
            }
        case .appleSignedIn:
            if let userProfile = viewModel.appleUserProfile {
                content.text = userProfile.name
            }
        case .signedOut:
            content.text = "Login"
        }
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch viewModel.state {
        case .googleSignedIn, .appleSignedIn:
            let userProfileVC = UserProfileViewController()
            show(userProfileVC, sender: self)
        case .signedOut:
            let signInVC = SignInViewController()
            show(signInVC, sender: self)
        }
    }
}
