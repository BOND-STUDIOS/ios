import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    // Add some padding at the top to space things out
                    .padding(.top, 40)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button(action: {
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }

                Button(action: {
                    Auth.auth().createUser(withEmail: email, password: password) { result, error in
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }) {
                    Text("Create Account")
                        .font(.headline)
                }
                
                // The Spacer() has been removed to prevent the layout crash.
                // We add our own Spacer at the end of the VStack if we
                // want to push content to the top.
                Spacer()
            }
            .padding()
            .navigationTitle("Login")
            // A subtle style change that often helps with navigation transitions
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
