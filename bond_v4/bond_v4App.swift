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
    @StateObject private var authViewModel: AuthenticationViewModel
    @StateObject private var audioPlayerService: AudioPlayerService
    @StateObject private var speechToTextService: SpeechToTextService
    @StateObject private var agentAPI: AgentAPI
    
    
    init() {
        let authVM = AuthenticationViewModel()
        let audioPlayer = AudioPlayerService()
        let speechService = SpeechToTextService()
        let agent = AgentAPI()
        
        _authViewModel = StateObject(wrappedValue: authVM)
        _audioPlayerService = StateObject(wrappedValue: audioPlayer)
        _speechToTextService = StateObject(wrappedValue: speechService)
        _agentAPI = StateObject(wrappedValue: agent)
    }
    var body: some Scene {
        WindowGroup {
          ContentView()
            .environmentObject(authViewModel)
            .environmentObject(agentAPI)
            .environmentObject(audioPlayerService)
            .environmentObject(speechToTextService)
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

