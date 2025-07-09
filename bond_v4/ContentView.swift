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
    var body: some View {
        return Group {
          NavigationView {
            switch authViewModel.state {
            case .signedIn:
              UserProfileView()
                .navigationTitle(
                  NSLocalizedString(
                    "User Profile",
                    comment: "User profile navigation title"
                  ))
            case .signedOut:
              SignInView()
                .navigationTitle(
                  NSLocalizedString(
                    "Sign-in with Google",
                    comment: "Sign-in navigation title"
                  ))
            }
          }
          #if os(iOS)
          .navigationViewStyle(StackNavigationViewStyle())
          #endif
        }
    }
}

#Preview {
    ContentView()
}
