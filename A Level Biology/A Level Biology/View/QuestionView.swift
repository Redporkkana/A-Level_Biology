
// Quiz questions view

import SwiftUI

struct QuestionView: View {
    let question: Question
    @Binding var selectedAnswer: String?
    @Binding var isAnswered: Bool
    @Binding var score: Int

    var body: some View {
        VStack(spacing: 10) {
            Text(question.question)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            // Display image if image_url is not nil
            if let imageUrl = question.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(maxWidth: 500)
                        .cornerRadius(10)
                        .padding()
                } placeholder: {
                    ProgressView()
                }
            }
            
            ForEach(question.options, id: \ .self) { option in
                Button(action: {
                    if !isAnswered {
                        selectedAnswer = option
                        isAnswered = true
                        if option == question.correctAnswer {
                            score += 1
                        }
                    }
                }) {
                    Text(option)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(buttonBackground(for: option))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func buttonBackground(for option: String) -> Color {
        if isAnswered {
            return option == question.correctAnswer ? Color.green : (option == selectedAnswer ? Color.red : Color.gray)
        }
        return Color.gray
    }
}
/*
import SwiftUI

struct QuestionView: View {
    let question: Question
    @Binding var selectedAnswer: String?
    @Binding var isAnswered: Bool
    @Binding var score: Int

    var body: some View {
        VStack(spacing: 10) {
            ForEach(question.options, id: \.self) { option in
                Button(action: {
                    if !isAnswered {
                        selectedAnswer = option
                        isAnswered = true
                        if option == question.correctAnswer {
                            score += 1
                        }
                    }
                }) {
                    Text(option)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(buttonBackground(for: option))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
    }

    private func buttonBackground(for option: String) -> Color {
        if isAnswered {
            return option == question.correctAnswer ? Color.green : (option == selectedAnswer ? Color.red : Color.gray)
        }
        return Color.gray
    }
}
*/
