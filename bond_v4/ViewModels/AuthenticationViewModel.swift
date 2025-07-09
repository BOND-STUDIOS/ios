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
    private var authenticator: GoogleSignInAuthenticator {
        return GoogleSignInAuthenticator(authViewModel: self)
    }
    
    // --- This computed property remains the same ---
    var authorizedScopes: [String] {
        switch state {
        case .signedIn(let user, _): // Update to ignore the new idToken value
            return user.grantedScopes ?? []
        case .signedOut:
            return []
        }
    }
    
    // ✅ ADD THIS: A computed property to safely access the idToken
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
        authenticator.signIn()
    }

    func signOut() {
        authenticator.signOut()
    }

    func disconnect() {
        authenticator.disconnect()
    }
}

extension AuthenticationViewModel {
    enum State {
        // ✅ UPDATE THIS: Add the idToken to the signedIn case
        case signedIn(user: GIDGoogleUser, idToken: String)
        case signedOut
    }
}
