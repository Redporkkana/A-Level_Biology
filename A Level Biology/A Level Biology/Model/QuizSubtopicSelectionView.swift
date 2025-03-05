
// Questions in topics organised under subtopics

import SwiftUI

struct QuizSubtopicSelectionView: View {
    let topic: String
    let subtopics: [String]
    let questionsBySubtopic: [String: [Question]] // Dictionary: subtopic → questions

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Choose a subtopic")
                    .font(.headline)
                    .fontWeight(.bold)

                ForEach(subtopics, id: \.self) { subtopic in
                    if let subtopicQuestions = questionsBySubtopic[subtopic] {
                        NavigationLink(destination: QuizView(
                            topic: subtopic,
                            questions: subtopicQuestions
                        )) {
                            Text(subtopic)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("\(topic) - Subtopics")
    }
}
