//
//  GoogleService.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/8/25.
//
import Foundation
import GoogleSignIn


final class GoogleSignInAuthenticator: ObservableObject {

    enum AuthenticationError: Error{
        case noRootViewController
        case signInError(Error)
        case noUser
        case tokenRefreshError(Error)
        case nonceMismatch
        case tokenError
    }
    
    func signIn(completion: @escaping (Result<(user: GIDGoogleUser, idToken: String), Error>) -> Void) {
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                completion(.failure(AuthenticationError.noRootViewController))
                return
            }
            let manualNonce = UUID().uuidString
            
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController,
                hint: nil,
                additionalScopes: nil,
                nonce: manualNonce
            ) { signInResult, error in
                if let error = error{
                    completion(.failure(AuthenticationError.signInError(error)))
                    return
                }
                guard let user = signInResult?.user else{
                    completion(.failure(AuthenticationError.noUser))
                    return
                }

                // 1. Refresh the token to ensure it's not expired
                user.refreshTokensIfNeeded { refreshedUser, refreshError in
                    if let refreshError = refreshError {
                        completion(.failure(AuthenticationError.tokenRefreshError(refreshError)))
                        return
                    }
                    
            
                    guard let user = refreshedUser else {
                        completion(.failure(AuthenticationError.noUser))
                        return
                    }

                    // 2. Perform your nonce check with the guaranteed fresh token
                    guard let idToken = user.idToken?.tokenString,
                          let returnedNonce = self.decodeNonce(fromJWT: idToken),
                          returnedNonce == manualNonce else {
                        completion(.failure(AuthenticationError.nonceMismatch))
                        return
                    }
                    completion(.success((user: user, idToken: idToken)))
                    // 3. All checks passed, update the state with the user and the token
                    }
                }
            }
    /// Signs out the current user.
    func signOut() {
      GIDSignIn.sharedInstance.signOut()
    }

    /// Disconnects the previously granted scope and signs the user out.
    func disconnect(completion: @escaping (Error?) -> Void) {
        GIDSignIn.sharedInstance.disconnect(completion: completion)
    }

        }
    






private extension GoogleSignInAuthenticator {
  func decodeNonce(fromJWT jwt: String) -> String? {
    let segments = jwt.components(separatedBy: ".")
    guard let parts = decodeJWTSegment(segments[1]),
          let nonce = parts["nonce"] as? String else {
      return nil
    }
    return nonce
  }

  func decodeJWTSegment(_ segment: String) -> [String: Any]? {
    guard let segmentData = base64UrlDecode(segment),
          let segmentJSON = try? JSONSerialization.jsonObject(with: segmentData, options: []),
          let payload = segmentJSON as? [String: Any] else {
      return nil
    }
    return payload
  }

  func base64UrlDecode(_ value: String) -> Data? {
    var base64 = value
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length
    if paddingLength > 0 {
      let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
      base64 = base64 + padding
    }
    return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
  }
}
