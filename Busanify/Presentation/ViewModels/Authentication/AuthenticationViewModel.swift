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
import Combine

enum State {
    case googleSignedIn(GIDGoogleUser)
    case appleSignedIn
    case signedOut
}

final class AuthenticationViewModel {
    
    static let shared = AuthenticationViewModel(signInApi: SignInApi()) // 싱글톤 패턴
    
    @Published var state: State = .signedOut
    @Published var appleUserProfile: UserProfile?
    private let signInApi: SignInApi
    private let keyChain = Keychain()
    
    var cancellables = Set<AnyCancellable>()
    
    var authorizedScopes: [String] {
        switch state {
        case .googleSignedIn(let user):
            return user.grantedScopes ?? []
        case .appleSignedIn, .signedOut:
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
            self.state = .googleSignedIn(user)
            self.signInApi.saveGoogleUser(idToken: idToken)
        }
    }
    
    func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
        self.state = .signedOut
    }
    
    // 로그인 상태 복원
    func restorePreviousGoogleSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let user = user {
                self?.state = .googleSignedIn(user)
            } else {
                self?.state = .signedOut
                if let error = error {
                    print("There was an error restoring the previous sign-in: \(error)")
                }
            }
        }
    }
    
    func appleSignIn(code: String, username: String, userId: String) {
        self.signInApi.saveAppleUser(code: code, username: username) { [weak self] result in
            switch result {
            case .success(let accessToken):
                print(accessToken)
                self?.keyChain.save(key: "appleAccessToken", value: accessToken)
                self?.keyChain.save(key: "appleUserId", value: userId)
                DispatchQueue.main.async {
                    self?.getAppleUserProfile()
                    self?.state = .appleSignedIn
                }
            case .failure(let error):
                print("Error saving Apple user: \(error)")
                DispatchQueue.main.async {
                    self?.state = .signedOut
                }
            }
        }
    }
    
    func appleSignOut() {
        self.keyChain.delete(key: "appleAccessToken")
        self.keyChain.delete(key: "appleUserId")
        self.state = .signedOut
    }
    
    func restorePreviousAppleSignIn() {
        guard let userId = self.keyChain.read(key: "appleUserId") else {
            print("No valid user ID")
            return
        }

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userId) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                print("authorized")
                DispatchQueue.main.async {
                    self.getAppleUserProfile()
                    self.state = .appleSignedIn
                }
            case .revoked:
                print("revoked")
                DispatchQueue.main.async {
                    self.state = .signedOut
                }
            case .notFound:
                print("notFound")
                DispatchQueue.main.async {
                    self.state = .signedOut
                }
            default:
                break
            }
        }
    }
    
    func getAppleUserProfile() {
        guard let accessToken = self.keyChain.read(key: "appleAccessToken") else {
            return
        }
        
        self.signInApi.getAppleUserProfile(accessToken: accessToken)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                self?.appleUserProfile = userProfile
            }
            .store(in: &cancellables)
    }
}
