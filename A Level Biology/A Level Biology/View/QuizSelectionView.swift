
// Quizzes grouped by topics

import SwiftUI

struct QuizSelectionView: View {
    @StateObject private var authViewModel = AuthViewModel() // Ensures initialization
    @StateObject private var userProgressManager = UserProgressManager()
    @StateObject private var topicLoader = TopicLoader()
    @StateObject private var questionLoader = QuestionLoader()
    @State private var selectedTopic: String? = nil

    var body: some View {
     
            ScrollView {
                
                VStack(spacing: 10) {
                    
                    Spacer(minLength: 20)
                    if !authViewModel.isSignedIn {
                        NavigationLink(destination: SignInView()
                            .environmentObject(authViewModel)
                            .environmentObject(userProgressManager)) { // Pass authViewModel
                            
                                Text("Sign in to track your progress")
                                    .font(.system(.headline, design: .monospaced))
                                    .foregroundColor(.blue)
                                    .minimumScaleFactor(0.7)
                            }
                    }
                    if topicLoader.topics.isEmpty {
                        Text("No quizzes available.")
                            .foregroundColor(.gray)
                    } else {
                        
                        let filteredTopics = getFilteredTopics()

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))], spacing: 20) {
                            ForEach(filteredTopics, id: \.topic.id) { topicData in
                                NavigationLink(destination: QuizSubtopicSelectionView(
                                    topic: topicData.topic.title,
                                        subtopics: Array(Set(topicData.questions.map { $0.subtopic })), // Extract unique subtopics
                                        questionsBySubtopic: Dictionary(grouping: topicData.questions, by: { $0.subtopic }) // Group questions by subtopic
                                )
                                .environmentObject(authViewModel) // Ensure this is passed
                                .environmentObject(userProgressManager)
                                ) {
                                    TopicButtonView(topic: topicData.topic, questions: topicData.questions)
                                }

                            }
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                
                .navigationBarBackButtonHidden(true)
            }
            .padding(.bottom, 20)
            .background(Color(.systemBackground))
            .scrollIndicators(.visible)
            .environmentObject(authViewModel) // Ensure it’s passed to the full navigation stack
            .environmentObject(userProgressManager)
            .onAppear {
                topicLoader.loadTopics()

            }
            
        
    }

    private func getFilteredTopics() -> [(topic: Topic, questions: [Question])] {
        return topicLoader.topics.map { topic in
            let topicQuestions = questionLoader.questions.filter { $0.topic == topic.title }.shuffled()
            return (topic, topicQuestions)
        }
    }
}
