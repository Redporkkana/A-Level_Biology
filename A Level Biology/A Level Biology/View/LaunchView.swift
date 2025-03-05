// App's Home screen

import SwiftUI

struct LaunchView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userProgressManager = UserProgressManager()
    @State private var reloadTrigger = false
    @State private var showStatsView = false // Controls navigation to stats page

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    Spacer(minLength: 10)

                    // Show "View Your Stats" Only If Signed In
                    if authViewModel.isSignedIn {
                        Button(action: {
                            showStatsView = true // Trigger stats navigation
                        }) {
                            Text("View your stats")
                                .font(.system(.headline, design: .monospaced))
                                .foregroundColor(.blue)
                                .padding()
                        }
                    } else {
                        NavigationLink(destination: SignInView()
                            .environmentObject(authViewModel)
                            .environmentObject(userProgressManager)) {
                                Text("Sign in to track your progress")
                                    .font(.system(.headline, design: .monospaced))
                                    .foregroundColor(.blue)
                                    .minimumScaleFactor(0.7)
                        }
                    }

                    Divider()
                        .shadow(radius: 5)

                    // Display Flashcards Section
                    if !userProgressManager.progress.flashcards.isEmpty {
                        Button(action: {
                            reloadTrigger.toggle() // Force reload
                            userProgressManager.loadProgress() // Reload user data
                                }) {
                                        Text("🔄 SAVED FLASHCARDS")
                                            .font(.headline)
                                            .padding(.top)
                                    }
                        TabView {
                            ForEach(userProgressManager.progress.flashcards) { flashcard in
                                VStack(alignment: .leading) {
                                    Text(flashcard.question)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .italic()
                                        .minimumScaleFactor(0.5)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.orange)).shadow(radius: 5)

                                    Text(flashcard.keywords.joined(separator: ", "))
                                        .font(.system(.body, design: .monospaced))
                                        .minimumScaleFactor(0.5)
                                        .bold()
                                        .padding(10)
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(flashcard.longAnswer)
                                        .font(.body)
                                        .foregroundColor(.black)
                                        .minimumScaleFactor(0.5)
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Button("Remove") {
                                        userProgressManager.removeFlashcard(id: flashcard.id)
                                    }
                                    .foregroundColor(.gray)
                                    .minimumScaleFactor(0.5)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
                                .padding()
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(minHeight: 500)

                        Text("swipe to see more")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        VStack(alignment: .center) {
                            Text("Your saved flashcards will appear here")
                                .font(.body)
                                .minimumScaleFactor(0.5)
                                .padding()
                            Button(action: {
                                    reloadTrigger.toggle() // Force reload
                                    userProgressManager.loadProgress() // Reload user data
                                    }) {
                                        Text("🔄")
                                            .font(.largeTitle)
                            }
                            
                            Text("Complete quizzes and past papers and save flashcards to review later")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .padding(30)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground))
            .scrollIndicators(.visible)
            .padding(.bottom, 20)
            .environmentObject(authViewModel)
            .environmentObject(userProgressManager)
        
            // Trigger Navigation to Stats View
            .navigationDestination(isPresented: $showStatsView) {
                SignInView()
                    .environmentObject(authViewModel)
                    .environmentObject(userProgressManager)
            }
        }
    }
}

