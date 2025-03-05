
// Formatted button for navigating to subtopics

import SwiftUI

struct TopicButtonView: View {
    let topic: Topic
    let questions: [Question]

    var body: some View {
        NavigationLink(destination: QuizSubtopicSelectionView(
            topic: topic.title,
            subtopics: Array(Set(questions.map { $0.subtopic })), // Extract unique subtopics
            questionsBySubtopic: Dictionary(grouping: questions, by: { $0.subtopic }) // Group by subtopic
        )) {
            VStack {
                Text(topic.title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 5)
            }
            .frame(maxWidth: .infinity, minHeight: 150)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .shadow(radius: 2)
        }
    }
}

