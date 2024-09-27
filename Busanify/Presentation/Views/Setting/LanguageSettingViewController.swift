//
//  LanguageSettingViewController.swift
//  Busanify
//
//  Created by seokyung on 9/27/24.
//

import UIKit

class LanguageSettingViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let languages = ["English", "简体中文", "繁體中文", "日本語"]
    private let languageCodes = ["en", "zh-Hans", "zh-Hant", "ja"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        enableInteractivePopGesture()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("language", comment: "")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LanguageCell")
    }
    
    private func getCurrentLanguageCode() -> String {
        let currentLangs = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String] ?? []
        if let firstLang = currentLangs.first {
            if firstLang.starts(with: "zh") {
                return firstLang
            }
            return firstLang.components(separatedBy: "-").first ?? firstLang
        }
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    private func isMatchingLanguageCode(_ code: String, with currentCode: String) -> Bool {
        if code.starts(with: "zh") {
            return code == currentCode
        } else {
            return code.starts(with: currentCode)
        }
    }
}

extension LanguageSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath)
        cell.textLabel?.text = languages[indexPath.row]
        
        let currentLangCode = getCurrentLanguageCode()
        if isMatchingLanguageCode(languageCodes[indexPath.row], with: currentLangCode) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLang = languageCodes[indexPath.row]
        UserDefaults.standard.set([selectedLang], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        tableView.reloadData()
        
        let alert = UIAlertController(title: NSLocalizedString("languageChanged", comment: ""),
                                      message: NSLocalizedString("restartApp", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { _ in
            exit(0) // 앱 재시작
        })
        present(alert, animated: true)
    }
}
