//
//  GoogleAuthenticationViewModel.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/8/25.
//


import SwiftUI
import GoogleSignIn

final class AuthenticationViewModel: ObservableObject {
    @Published var state: State

    private let authenticator = GoogleSignInAuthenticator()
   
    var idToken: String? {
        switch state {
        case .signedIn(_, let idToken):
            return idToken
        case .signedOut:
            return nil
        }
    }

    init() {
        // Check for existing signed-in user on launch
        if let user = GIDSignIn.sharedInstance.currentUser, let idToken = user.idToken?.tokenString {
            self.state = .signedIn(user: user, idToken: idToken)
        } else {
            self.state = .signedOut
        }
    }

    // --- These methods remain the same ---
    func signIn() {
        authenticator.signIn { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let (user, idToken)):
                    self?.state = .signedIn(user: user, idToken: idToken)
                case .failure(let error):
                    print("Sign-in error: \(error.localizedDescription)")
                    self?.state = .signedOut
                }
            }
        }
    }

    func signOut() {
        authenticator.signOut()
        self.state = .signedOut
    }

    func disconnect() {
        authenticator.disconnect { [weak self] error in
            if let error = error {
                print("Error disconnecting: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self?.signOut()
            }
        }
    }
}

extension AuthenticationViewModel {
    enum State {
        // ✅ UPDATE THIS: Add the idToken to the signedIn case
        case signedIn(user: GIDGoogleUser, idToken: String)
        case signedOut
    }
}
