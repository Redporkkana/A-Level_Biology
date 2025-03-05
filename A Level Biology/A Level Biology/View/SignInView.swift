// Section for displaying account based information (saved progress)

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userProgressManager: UserProgressManager
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isSigningUp = false // Toggle for sign-in/sign-up
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteAlert = false



    var body: some View {
        VStack(spacing: 30) {
            if authViewModel.isSignedIn {
                // Signed-In View: Show Progress
                signedInView()
            } else {
                // Authentication Form
                VStack {
                    Spacer()
                    Text(isSigningUp ? "Create an Account" : "Sign In to Your Account")
                        .font(.title2)
                        .bold()
                        .padding()
                     

                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    Spacer()
                    Button(isSigningUp ? "Sign Up" : "Sign In") {
                        if isSigningUp {
                            authViewModel.signUp(email: email, password: password) { result in
                                handleAuthResult(result)
                            }
                        } else {
                            authViewModel.login(email: email, password: password) { result in
                                handleAuthResult(result)
                            }
                        }
                    }
                    .padding()
                    .frame(width: 250)
                    .background(LinearGradient(colors: [.mint, .cyan], startPoint: .top, endPoint: .bottom))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer()

                    // Toggle Sign-In / Sign-Up
                    Button(isSigningUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up") {
                        isSigningUp.toggle()
                    }
                    .font(.caption)
                    .padding(.top, 5)
                    
                    Spacer()

                    // Password Reset
                    if !isSigningUp {
                        Button("Forgot Password?") {
                            authViewModel.resetPassword(email: email) { error in
                                if let error = error {
                                    errorMessage = error.localizedDescription
                                } else {
                                    errorMessage = "Password reset email sent!"
                                }
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.top, 5)
                    }
                }
            }
        }
        .onAppear {
            userProgressManager.loadProgress()
        }
    }

    // Handle Authentication Result
    private func handleAuthResult(_ result: Result<User, Error>) {
        switch result {
        case .success(let user):
            print("User authenticated: \(user.email ?? "No Email")")
            errorMessage = nil
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    // Signed-In View (Progress Tracking)
    @ViewBuilder
    private func signedInView() -> some View {
        VStack {
            Text("Account: \(authViewModel.userEmail)")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top, 10)
            // Show Average Paper Completion Match %
            Text("Your paper completion progress")
                .font(.title2)
                .bold()
                .foregroundColor(.cyan)
                .padding(.top, 10)
            
            if userProgressManager.progress.completedPapers.isEmpty {
                Text("No papers completed yet.")
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            } else {
                Text("Papers Completed: \(userProgressManager.progress.completedPapers.count)")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            
            }
            Text("Your quiz progress")
                .font(.title2)
                .foregroundColor(.cyan)
                .bold()
                .padding(10)

            if userProgressManager.progress.completedQuizzesWithTimestamps.isEmpty {
                Text("No quizzes completed yet.")
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            } else {
                List(userProgressManager.progress.completedQuizzesWithTimestamps.sorted(by: { $0.value.timestamp > $1.value.timestamp }), id: \.key) { topic, details in
                    VStack(alignment: .leading) {
                        Text("📖 \(topic)").font(.headline)
                        Text("Score: \(details.score)/\(details.totalQuestions)")
                            .foregroundColor(Double(details.score)/Double(details.totalQuestions) < 0.7 ? .red : .green)
                        Text("Completed on: \(details.timestamp.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)
                }
            }
            
            // Weak Topics Feedback
            if !userProgressManager.progress.weakTopics.isEmpty {
                Text("You need more practice in these topics:")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.red)
                    .padding(.top)

                ForEach(userProgressManager.progress.weakTopics, id: \.self) { topic in
                    Text("⚠️ \(topic)")
                        .font(.headline)
                        .padding(.vertical, 2)
                }
            } else {
                Image(systemName: "hand.thumbsup")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
                    .padding(.horizontal, 20)
                Text("You are doing great!")
                    .foregroundColor(.green)
                    .padding()
            }

            // Navigation & Logout Options
            Button("Back to Home") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.cyan)
            .foregroundColor(.white)
            .cornerRadius(10)
            .frame(width: 300)


            Button("Sign Out") {
                authViewModel.signOut()
            }
            .padding()
            .foregroundColor(.gray)
            .cornerRadius(10)
            .frame(width: 300)

            Button("Delete My Account") {
                showDeleteAlert = true // Show confirmation dialog
            }
            .font(.caption2)
            .padding()
            .cornerRadius(10)
            .frame(minWidth: 300)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Confirm Account Deletion"),
                    message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        authViewModel.deleteUserAccount()
                    },
                    secondaryButton: .cancel()
                )
            }

        }
    }
}

