//
//  AuthenticationViewModel.swift
//  Busanify
//
//  Created by 이인호 on 6/27/24.
//
// https://developers.google.com/identity/sign-in/ios/start-integrating?hl=ko 참조

import Foundation
import GoogleSignIn
import AuthenticationServices

enum State {
    case signedIn(GIDGoogleUser)
    case signedOut
}

final class AuthenticationViewModel {
    
    static let shared = AuthenticationViewModel(signInApi: SignInApi()) // 싱글톤 패턴
    
    @Published var state: State = .signedOut
    private let signInApi: SignInApi
    
    var authorizedScopes: [String] {
        switch state {
        case .signedIn(let user):
            return user.grantedScopes ?? []
        case .signedOut:
            return []
        }
    }
    
    var currentUser: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }
    
    init(signInApi: SignInApi) {
        self.signInApi = signInApi
        restorePreviousGoogleSignIn()
        restorePreviousAppleSignIn()
    }
    
    func googleSignIn() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        guard let rootViewController = window?.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            let user = signInResult.user
            
            guard let idToken = user.idToken?.tokenString else { return }
            
            print(idToken)
            self.state = .signedIn(user)
            self.signInApi.saveGoogleUser(idToken: idToken)
        }
    }
    
    func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
        self.state = .signedOut
    }
    
    func appleSignIn(code: String) {
        self.signInApi.saveAppleUser(code: code)
    }
    
    // 로그인 상태 복원
    func restorePreviousGoogleSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let user = user {
                self?.state = .signedIn(user)
            } else {
                self?.state = .signedOut
                if let error = error {
                    print("There was an error restoring the previous sign-in: \(error)")
                }
            }
        }
    }
    
    func restorePreviousAppleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: "000980.f7a9d20e8233436aa3f90c7ec12d4063.0020") { (credentialState, error) in
            switch credentialState {
            case .authorized:
                print("authorized")
            case .revoked:
                print("revoked")
            case .notFound:
                print("notFound")
            default:
                break
            }
        }
    }
}
