//
//  bond_v4App.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/7/25.
//

import SwiftUI
import GoogleSignIn

@main
struct bond_v4App: App {
    @StateObject var authViewModel = AuthenticationViewModel()
    @StateObject private var agentAPI = AgentAPI()
    @StateObject private var audioPlayerService = AudioPlayerService()

    var body: some Scene {
        WindowGroup {
          ContentView()
            .environmentObject(authViewModel)
            .environmentObject(agentAPI)
            .environmentObject(audioPlayerService)
            .onAppear {
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let user = user, let idToken = user.idToken?.tokenString {
                        self.authViewModel.state = .signedIn(user: user, idToken: idToken)
                    } else {
                        self.authViewModel.state = .signedOut
                        if let error = error {
                            print("There was an error restoring the previous sign-in: \(error)")
                        }
                    }
                }
            }
            .onOpenURL { url in
              GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}

