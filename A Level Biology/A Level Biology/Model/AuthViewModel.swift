// Authorisation object model. In use with Firebase, SIWA can be implemented if needed

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import UIKit


class AuthViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published var isSignedIn: Bool = UserDefaults.standard.bool(forKey: "isSignedIn")
    @Published var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @Published var userEmail: String = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    @Published var errorMessage: String?
    
    
    override init() {
        super.init()
        checkSignInStatus() // Ensure session is restored at app launch
    }

    // Sign up with email and password (Firebase)
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                completion(.failure(error))
            } else if let user = authResult?.user {
                DispatchQueue.main.async {
                    self.isSignedIn = true
                    self.userEmail = user.email ?? ""
                    UserDefaults.standard.set(true, forKey: "isSignedIn")
                    UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                    self.errorMessage = nil
                }
                completion(.success(user))
            }
        }
    }

    // Login with email and password
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                completion(.failure(error))
            } else if let user = authResult?.user {
                DispatchQueue.main.async {
                    self.isSignedIn = true
                    self.userEmail = user.email ?? ""
                    UserDefaults.standard.set(true, forKey: "isSignedIn")
                    UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                    self.errorMessage = nil
                }
                completion(.success(user))
            }
        }
    }

    // Reset password
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.errorMessage = "Password reset email sent!"
                }
            }
            completion(error)
        }
    }

    // Logout (Can handles both Apple & email sign-In)
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("❌ Firebase sign-out error: \(error.localizedDescription)")
        }

        // Clear stored credentials
        isSignedIn = false
        userName = ""
        userEmail = ""

        UserDefaults.standard.set(false, forKey: "isSignedIn")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "appleUserID")
    }


    //  Apple Sign-in integration
    func signInWithApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign-in failed: \(error.localizedDescription)")
    }


    // Checking sign in status
    
    func checkSignInStatus() {
        if let appleUserID = UserDefaults.standard.string(forKey: "appleUserID") {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: appleUserID) { (credentialState, error) in
                DispatchQueue.main.async {
                    switch credentialState {
                    case .authorized:
                        self.isSignedIn = true
                    case .revoked, .notFound:
                        self.signOut()
                    default:
                        break
                    }
                }
            }
        }
    }

    
    // Delete the user account
    
    func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else { return }

        //  Check if re-authentication is required
        user.reload { error in
            if let error = error {
                print("Error reloading user: \(error.localizedDescription)")
                self.errorMessage = "Re-authentication required. Please sign in again."
                return
            }

            // Proceed with account deletion
            user.delete { error in
                if let error = error {
                    print("Error deleting account: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    return
                }

                // Account deletion confirmation
                print("Account deleted successfully")
                self.isSignedIn = false
                self.userEmail = ""
                UserDefaults.standard.set(false, forKey: "isSignedIn")
                UserDefaults.standard.removeObject(forKey: "userEmail")

                // Log out the user
                do {
                    try Auth.auth().signOut()
                } catch let signOutError {
                    print("Error signing out: \(signOutError.localizedDescription)")
                }
            }
        }
    }


    //Display alert for account deletion conformation
    func showDeleteAccountConfirmation(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Confirm Account Deletion",
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        // Cancel Action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Delete Action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteUserAccount()
        }))
        
        // Show Alert
        viewController.present(alert, animated: true, completion: nil)
    }
}

// Required for Apple Sign-In Presentation
extension AuthViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first }
            .first ?? UIWindow()
    }
}
