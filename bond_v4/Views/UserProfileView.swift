//
//  UserProfileView.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/8/25.
//




import SwiftUI
import GoogleSignIn

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var agentAPI: AgentAPI
    @EnvironmentObject var audioPlayerService: AudioPlayerService

    var body: some View {
        VStack(spacing: 20) {
            Button("Sign Out", action: authViewModel.disconnect)
            Button("Test API Call") {
                Task {
                    await agentAPI.sendPrompt("I was just kidding lol.", using: authViewModel, audioPlayer: audioPlayerService)
                }
            }
        }
        .padding()
    }
}
