//
//  AppDelegate.swift
//  Busanify
//
//  Created by 이인호 on 6/16/24.
//

import UIKit
import KakaoMapsSDK
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let authenticationViewModel = AuthenticationViewModel.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let clientID = Bundle.main.object(forInfoDictionaryKey: "MAP_KEY") as? String {        
            SDKInitializer.InitSDK(appKey: clientID)
        }
        
        // 소셜로그인 유저 로그인 유지
        authenticationViewModel.restorePreviousGoogleSignIn()
        authenticationViewModel.restorePreviousAppleSignIn()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // 인증 리디렉션 URL 처리
        func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            var handled: Bool
            
            handled = GIDSignIn.sharedInstance.handle(url)
            if handled {
                return true
            }
            
            // Handle other custom URL types.
            
            // If not handled by this app, return false.
            return false
        }
}

