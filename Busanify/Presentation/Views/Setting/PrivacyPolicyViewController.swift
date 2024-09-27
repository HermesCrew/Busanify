//
//  PrivacyPolicyViewController.swift
//  Busanify
//
//  Created by 이인호 on 9/27/24.
//

import UIKit

var content: String {
    let languageCode = Locale.current.language.languageCode?.identifier
    let language = Locale.current.language
    
    if languageCode == "ja" {
        return """
                Busanify("App")は、ユーザーのプライバシーを高く評価し、適用される法律を遵守します。 当社のプライバシーポリシーは、ユーザーが提供する個人情報がどのように使用され、保護され、管理されるかを概説します。

                1. 個人情報の収集と利用の目的です
                このアプリは、ユーザーが便利なようにAppleとGoogleを介してログインすることを可能にします。 これらのログインを通じて収集された個人情報は、次の目的で使用されます:

                - ユーザー認証とアカウント管理を行います
                - サービスのプロビジョニングと改善を行います
                - ユーザーからの問い合わせや要望にお応えします
                - サービスの使用状況の統計と分析です

                2. 収集された個人情報のカテゴリです
                Apple および Google ログインを通じて収集される個人情報には、次のものが含まれます:

                - 名前です
                - メールアドレスです
                - プロフィール画像（オプション）です
                - ログイン関連情報（OAuth トークンなど）です

                3. 個人情報の保持と使用についてです
                ユーザー情報は、サービスを提供するために必要な期間保持され、適用される法律に従って目的が達成された後に安全に廃棄されます。 具体的な保存期間と使用期間は次のとおりです:

                - アカウントの作成と管理は次のとおりです: アカウントの削除要求までです
                - サービス利用記録:3年です

                4. 第三者による個人情報の開示です
                デフォルトでは、ユーザー情報は外部当事者に提供されません。 例外は次のとおりです:

                - ユーザーが事前に同意した場合です
                - 法律で定められている場合です

                5. 個人情報の保護についてです
                アプリは、ユーザー情報を保護するために以下の手段を採用しています:

                - データを暗号化します
                - アクセス制御と認証の手順です
                - 定期的なセキュリティチェックと改善が行われます

                6. ユーザーの権利と責任です
                ユーザーは、いつでも個人情報の表示、変更、または削除を要求することができます。 また、ユーザーはプライバシー関連の法律を遵守する義務があり、他人のプライバシーを侵害してはなりません。

                7. ポリシーの変更を通知します
                プライバシーポリシーが変更された場合、アプリ内の告知を通じて、少なくとも実施7日前にユーザーに通知されます。
                このポリシーは2024年9月27日から有効です。
                """
    } else if languageCode == "zh" {
        if language.script?.identifier == "Hans" {
            return """
                    Busanify（"App"）重视用户隐私并遵守适用法律。 我们的隐私政策概述了如何使用、保护和管理用户提供的个人信息。

                    1. 这是为了收集和使用个人信息。
                    该应用程序允许用户通过Apple和Google登录以方便用户。 通过这些登录收集的个人信息用于以下目的:

                    - 用户身份验证和帐户管理
                    - 提供和改进服务
                    - 响应用户询问和请求
                    - 服务使用统计和分析

                    2. 收集的个人信息的类别
                    通过 Apple 和 Google 登录收集的个人信息包括:

                    - 这是我的名字
                    - 这是您的电子邮件地址
                    - 这是一个可选的个人资料图片
                    - 登录相关信息，如OAuth令牌

                    3. 这是关于个人信息的保留和使用
                    用户信息将在提供服务所需的时间内保留，并在根据适用法律达到目的后安全丢弃。 具体的保质期和使用期限包括:

                    - 创建和管理帐户如下: 这是直到请求删除帐户
                    - 服务使用记录:3年

                    4. 这是第三方披露的个人信息
                    默认情况下，用户信息不会提供给外部方。 例外情况包括:

                    - 如果用户提前同意
                    - 这是一个法律案例

                    5. 它是关于保护个人信息
                    该应用程序使用以下方法保护用户信息:

                    - 加密数据
                    - 访问控制和认证程序
                    - 定期进行安全检查和改进

                    6. 这是用户的权利和义务
                    用户可以随时要求显示、更改或删除其个人信息。 此外，用户有义务遵守隐私法，不应侵犯他人的隐私。

                    7. 通知政策变更
                    如果隐私政策发生变化，用户将在实施前至少7天通过应用内通知获得通知。
                    该政策自2024年9月27日起生效。
                    """
        } else {
            return """
                Busanify（"App"）重視用戶隱私並遵守適用法律。 我們的隱私政策概述瞭如何使用、保護和管理用戶提供的個人信息。

                1. 這是爲了收集和使用個人信息。
                該應用程序允許用戶通過Apple和Google登錄以方便用戶。 通過這些登錄收集的個人信息用於以下目的:

                - 用戶身份驗證和帳戶管理
                - 提供和改進服務
                - 響應用戶詢問和請求
                - 服務使用統計和分析

                2. 收集的個人信息的類別
                通過 Apple 和 Google 登錄收集的個人信息包括:

                - 這是我的名字
                - 這是您的電子郵件地址
                - 這是一個可選的個人資料圖片
                - 登錄相關信息，如OAuth令牌

                3. 這是關於個人信息的保留和使用
                用戶信息將在提供服務所需的時間內保留，並在根據適用法律達到目的後安全丟棄。 具體的保質期和使用期限包括:

                - 創建和管理帳戶如下: 這是直到請求刪除帳戶
                - 服務使用記錄:3年

                4. 這是第三方披露的個人信息
                默認情況下，用戶信息不會提供給外部方。 例外情況包括:

                - 如果用戶提前同意
                - 這是一個法律案例

                5. 它是關於保護個人信息
                該應用程序使用以下方法保護用戶信息:

                - 加密數據
                - 訪問控制和認證程序
                - 定期進行安全檢查和改進

                6. 這是用戶的權利和義務
                用戶可以隨時要求顯示、更改或刪除其個人信息。 此外，用戶有義務遵守隱私法，不應侵犯他人的隱私。

                7. 通知政策變更
                如果隱私政策發生變化，用戶將在實施前至少7天通過應用內通知獲得通知。
                該政策自2024年9月27日起生效。
                """
        } 
    } else {
        return """
                Busanify("App") highly values user privacy and complies with applicable laws. Our privacy policy outlines how personal information provided by users is used, protected, and managed.

                1. Purpose of Collecting and Using Personal Information 
                The App allows users to log in via Apple and Google for convenience. The personal information collected through these logins is used for the following purposes:

                - User authentication and account management
                - Service provision and improvement
                - Responding to user inquiries and requests
                - Service usage statistics and analysis
                
                2. Categories of Personal Information Collected 
                The personal information collected through Apple and Google logins includes:

                - Name
                - Email address
                - Profile picture (optional)
                - Login-related information (OAuth tokens, etc.)
                
                3. Retention and Use of Personal Information
                User information is retained for the duration necessary to provide the service and is securely disposed of after the purpose is fulfilled in compliance with applicable laws. Specific retention and use periods are as follows:

                - Account creation and management: Until account deletion request
                - Service usage records: 3 years
                
                4. Third-Party Disclosure of Personal Information 
                The App does not provide user information to external parties by default. Exceptions include:

                - When the user has given prior consent
                - When required by law
                
                5. Protection of Personal Information 
                The App employs the following measures to safeguard user information:

                - Data encryption
                - Access control and authentication procedures
                - Regular security checks and improvements
                
                6. User Rights and Responsibilities 
                Users may request to view, modify, or delete their personal information at any time. Users are also obligated to comply with privacy-related laws and must not infringe upon the privacy of others.

                7. Notification of Policy Changes 
                If the privacy policy is modified, users will be notified at least 7 days before implementation through announcements within the App. 
                This policy is effective from September 27, 2024.
                """
    }
}

class PrivacyPolicyViewController: UIViewController {

    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupTextView()
        setupNavigationBar()
        title = NSLocalizedString("privacyPolicy", comment: "")
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTextView() {
        textView.text = content
    }
}
