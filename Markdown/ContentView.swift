//
//  ContentView.swift
//  Markdown
//
//  Created by CJ Sanchez on 7/22/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = false
    var body: some View {
        Group {
            if isLoggedIn {
                MainTaskView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { auth, user in
                self.isLoggedIn = (user != nil)
            }
        }
    }
}

#Preview {
    ContentView()
}
