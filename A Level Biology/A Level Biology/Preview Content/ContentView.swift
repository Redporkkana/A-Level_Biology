//
//  ContentView.swift
//  A Level Biology
//
//  Created by Easy Business Cloud on 04/02/2025.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userProgressManager = UserProgressManager()
    @StateObject private var paperLoader = PaperLoader()
    @StateObject private var topicLoader = TopicLoader()
    @StateObject private var questionLoader = QuestionLoader()
    @StateObject private var keywordLoader = KeywordLoader()
    
    @State private var selectedTopic: String? = nil
    @State private var selectedQuestions: [Question] = []
    @State private var showQuizSelection = false // ✅ Controls navigation

    var body: some View {
        NavigationStack {
            TabView {
                LaunchView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                QuizSelectionView()
                    .tabItem {
                        Label("Quizzes", systemImage: "microbe")
                    }

                PaperView()
                    .tabItem {
                        Label("Past Papers", systemImage: "brain.filled.head.profile")
                    }

                    .environmentObject(userProgressManager)

                KeywordsView()
                    .tabItem {
                        Label("Keywords", systemImage: "list.bullet.clipboard")
                    }

                
                    .environmentObject(authViewModel)
                    .environmentObject(userProgressManager)
            }
            .accentColor(.cyan)
            .background(Color.secondary)
            .opacity(1.0)
            
        }
    }
}
