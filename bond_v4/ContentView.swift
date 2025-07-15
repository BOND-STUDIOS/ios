//
//  ContentView.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/7/25.
//

import SwiftUI
import GoogleSignInSwift

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var agentAPI: AgentAPI
    var body: some View {
        return Group {
          NavigationView {
            switch authViewModel.state {
            case .signedIn:
              UserProfileView()
                .navigationTitle("User Profile")
            case .signedOut:
              SignInView()
                .navigationTitle("Sign-in with Google")
            }
          }
          .navigationViewStyle(StackNavigationViewStyle())
          .alert("Error", isPresented: .constant(agentAPI.errorMessage != nil), actions: {
              Button("OK") {
                  // Tapping OK will clear the error message to dismiss the alert.
                  agentAPI.errorMessage = nil
              }
          }, message: {
              // Display the error message from the AgentAPI.
              Text(agentAPI.errorMessage ?? "An unknown error occurred.")
          })
        }
    }
}

#Preview {
    ContentView()
}
