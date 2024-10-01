//
//  SignInAgreeView.swift
//  Busanify
//
//  Created by MadCow on 2024/10/1.
//

import UIKit

enum SignInType {
    case apple
    case google
}

class SignInAgreeView: UIViewController {
    
    var appleSigninDelegate: AppleSignDelegate?
    var googleSigninDelegate: GoogleSignDelegate?
    
    let selectedType: SignInType
    
    init(selectedType: SignInType) {
        self.selectedType = selectedType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("agree_title", comment: "")
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        return label
    }()
    
    let agreeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("agree_label", comment: "")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        setupNavigationBar()
        setupScrollView()
        setupLabel()
    }
    
    func setupNavigationBar() {
        self.view.backgroundColor = .white
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .done, target: self, action: #selector(cancelAgree))
        let agreeButton = UIBarButtonItem(title: NSLocalizedString("agree", comment: ""), style: .done, target: self, action: #selector(agreeAction))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = agreeButton
    }
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    func setupLabel() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(agreeLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            agreeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            agreeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            agreeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            agreeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func cancelAgree() {
        self.dismiss(animated: true)
    }
    
    @objc func agreeAction() {
        let defaults = UserDefaults.standard
        if let agreeData = try? JSONEncoder().encode("agreeComplete") {
            defaults.set(agreeData, forKey: "userAgree")
        }
        if self.selectedType == .apple {
            appleSigninDelegate?.signInApple()
        } else {
            googleSigninDelegate?.signInGoogle()
        }
        self.dismiss(animated: true)
    }
}

protocol AppleSignDelegate {
    func signInApple()
}

protocol GoogleSignDelegate {
    func signInGoogle()
}
