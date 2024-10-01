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
import FirebaseStorage

enum State: Equatable {
    case googleSignedIn(GIDGoogleUser)
    case appleSignedIn
    case signedOut
}

final class AuthenticationViewModel {
    
    static let shared = AuthenticationViewModel(signInApi: SignInApi()) // 싱글톤 패턴
    
    @Published var state: State = .signedOut
    @Published var currentUser: User? = nil
    private let signInApi: SignInApi
    private let keyChain = Keychain()
    
    var cancellables = Set<AnyCancellable>()
    
    init(signInApi: SignInApi) {
        self.signInApi = signInApi
    }
    
    func googleSignIn(completion: @escaping (Bool) -> Void) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        guard let rootViewController = window?.rootViewController else {
            print("There is no root view controller!")
            completion(false)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard error == nil, let signInResult = signInResult else {
                completion(false)
                return
            }
            
            let user = signInResult.user
            
            guard let idToken = user.idToken?.tokenString else {
                completion(false)
                return
            }
            
            print(idToken)
            self.state = .googleSignedIn(user)
            self.signInApi.saveGoogleUser(idToken: idToken) 
                .receive(on: DispatchQueue.main)
                .assign(to: &self.$currentUser)
            
            completion(true)
        }
    }
    
    func googleSignOut() {
        GIDSignIn.sharedInstance.signOut()
        self.state = .signedOut
        self.currentUser = nil
    }
    
    // 로그인 상태 복원
    func restorePreviousGoogleSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            // state 변경 메인 스레드에서
            DispatchQueue.main.async {
                if let user = user {
                    self?.state = .googleSignedIn(user)
                    self?.getUserProfile()
                } else {
                    self?.state = .signedOut
                    if let error = error {
                        print("There was an error restoring the previous sign-in: \(error)")
                    }
                }
            }
        }
    }
    
    func appleSignIn(code: String, userId: String, completion: @escaping (Bool) -> Void) {
        self.signInApi.saveAppleUser(code: code) { [weak self] result in
            switch result {
            case .success(let accessToken):
                print(accessToken)
                self?.keyChain.save(key: "appleAccessToken", value: accessToken)
                self?.keyChain.save(key: "appleUserId", value: userId)
                DispatchQueue.main.async {
                    self?.state = .appleSignedIn
                    self?.getUserProfile()
                    
                    completion(true)
                }
            case .failure(let error):
                print("Error saving Apple user: \(error)")
                DispatchQueue.main.async {
                    self?.state = .signedOut
                    
                    completion(false)
                }
            }
        }
    }
    
    func appleSignOut() {
        self.keyChain.delete(key: "appleAccessToken")
        self.keyChain.delete(key: "appleUserId")
        self.state = .signedOut
        self.currentUser = nil
    }
    
    func restorePreviousAppleSignIn() {
        guard let userId = self.keyChain.read(key: "appleUserId") else {
            print("No valid user ID")
            return
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userId) { (credentialState, error) in
            // state 변경 메인 스레드에서
            DispatchQueue.main.async {
                switch credentialState {
                case .authorized:
                    print("authorized")
                    DispatchQueue.main.async {
                        self.state = .appleSignedIn
                        self.getUserProfile()
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
    }
    
    func getUserProfile() {
        guard let token = self.getToken() else { return }
        
        self.signInApi.getUserProfile(token: token)
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }
    
    // 사용자 정보를 확인하여 서버에서 데이터를 요청할때 사용하는 토큰
    func getToken() -> String? {
        switch state {
        case .googleSignedIn(let user):
            guard let idToken = user.idToken?.tokenString else {
                return nil
            }
            return idToken
        case .appleSignedIn:
            guard let accessToken = self.keyChain.read(key: "appleAccessToken") else {
                return nil
            }
            return accessToken
        case .signedOut:
            return nil
        }
    }
    
    func updateProfileImage(data: Data, completion: @escaping (Bool) -> Void) {
        guard let token = self.getToken() else {
            completion(false)
            return
        }
        
        if let profileImage = self.currentUser?.profileImage {
            let imageRef = Storage.storage().reference(forURL: profileImage)
            imageRef.delete { error in
                if let error = error {
                    completion(false)
                }
            }
        }
        
        let storageReference = Storage.storage().reference().child("\(UUID().uuidString)")
        
        print("Uploading data to Firebase Storage")
        
        storageReference.putData(data, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error uploading data: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            storageReference.downloadURL { url, error in
                if error != nil {
                    completion(false)
                    return
                }
                
                guard let downloadURL = url else {
                    completion(false)
                    return
                }
                
                self.signInApi.updateUserProfile(token: token, profileImage: downloadURL.absoluteString, nickname: nil)
                    .receive(on: DispatchQueue.main)
                    .assign(to: &self.$currentUser)
                
                completion(true)
            }
        }
    }
    
    func deleteProfileImage(completion: @escaping (Bool) -> Void) {
        guard let token = self.getToken() else {
            completion(false)
            return
        }
        
        if let profileImage = self.currentUser?.profileImage {
            let imageRef = Storage.storage().reference(forURL: profileImage)
            imageRef.delete { error in
                if let error = error {
                    completion(false)
                }
            }
        }
        
        self.signInApi.updateUserProfile(token: token, profileImage: nil, nickname: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$currentUser)
        
        completion(true)
    }
    
    func updateProfileNickname(nickname: String, completion: @escaping (Bool) -> Void) {
        guard let token = self.getToken() else { return }
        
        self.signInApi.updateUserProfile(token: token, profileImage: self.currentUser?.profileImage, nickname: nickname)
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$currentUser)
        
        completion(true)
    }
    
    func deleteUser() {
        guard let token = self.getToken() else { return }
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "userAgree") != nil {
            defaults.removeObject(forKey: "userAgree")
            
//            defaults.synchronize()
        }
        switch state {
        case .googleSignedIn:
            self.signInApi.deleteUser(token: token, providerToDelete: "googleDelete") { success in
                if success {
                    GIDSignIn.sharedInstance.disconnect { error in
                        if let error = error {
                            print("Error disconnecting Google account: \(error.localizedDescription)")
                        } else {
                            self.state = .signedOut
                            self.currentUser = nil
                        }
                    }
                }
            }
        case .appleSignedIn:
            self.signInApi.deleteUser(token: token, providerToDelete: "appleDelete") { success in
                if success {
                    self.keyChain.delete(key: "appleAccessToken")
                    self.keyChain.delete(key: "appleUserId")
                    self.state = .signedOut
                    self.currentUser = nil
                }
            }
        default:
            return
        }
        
    }
}
