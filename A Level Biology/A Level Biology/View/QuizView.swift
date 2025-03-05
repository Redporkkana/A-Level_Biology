// Quiz logic and progress saving

import SwiftUI

struct QuizView: View {
    let topic: String
    let questions: [Question]

    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String? = nil
    @State private var isAnswered = false
    @State private var score = 0
    @State private var quizCompleted = false
    @State private var showConfirmation = false
    @State private var showExplanation = false
    @State private var currentSetIndex = 0
    let questionsPerSet = 10
    var currentSetQuestions: [Question] {
        let start = currentSetIndex * questionsPerSet
        let end = min(start + questionsPerSet, questions.count)
        return Array(questions[start..<end])
    }

    @Environment(\.dismiss) private var dismiss
    @StateObject private var authViewModel = AuthViewModel() // Ensures initialization
    @StateObject private var userProgressManager = UserProgressManager()

    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                if quizCompleted {
                    VStack {
                        Text("🎉 Quiz Completed!")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("You scored \(score) out of \(questions.count)")
                            .font(.title2)
                            .padding()

                        Button("Restart Quiz") {
                            restartQuiz()
                        }
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)

                        Button("Back to Topics") {
                            dismiss()
                        }
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                } else {
                    if questions.isEmpty {
                        Text("No questions yet. Check this section later.")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        let question = questions[currentQuestionIndex]

                        Text("🧪 \(topic) - Quiz")
                            .font(.headline)
                            .foregroundColor(.blue)

                        Text("Question \(currentQuestionIndex + 1) / \(questions.count)")
                            .font(.title2)
                            .padding()

                        Text(question.question)
                            .font(.title2)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()

                        // Options List
                        VStack(spacing: 10) {
                            ForEach(question.options, id: \.self) { option in
                                Button(action: {
                                    if !isAnswered {
                                        selectedAnswer = option
                                        isAnswered = true
                                        showExplanation = true

                                        if option == question.correctAnswer {
                                            score += 1
                                            provideHapticFeedback(isCorrect: true) // Haptic for correct answer
                                        } else {
                                            provideHapticFeedback(isCorrect: false) // Haptic for wrong answer
                                        }
                                    }
                                }) {
                                    Text(option)
                                        .padding()
                                        .frame(maxWidth: .infinity, minHeight: 60)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .background(buttonBackground(for: option, correctAnswer: question.correctAnswer))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Display Explanation
                        if showExplanation {
                            VStack {
                                Text("Explanation:")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text(question.explanation)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding()
                            
                            Button("Save as Flashcard") {
                                    userProgressManager.addFlashcard(
                                        question: question.question,
                                        keywords: [question.correctAnswer],
                                        longAnswer: question.explanation
                                    )
                                            showConfirmation = true
                                        
                                }
                                .font(.system(.callout, design: .monospaced))
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .alert(isPresented: $showConfirmation) {
                                    Alert(title: Text("Flashcard Saved"), message: Text("Your flashcard has been successfully saved!"), dismissButton: .default(Text("OK")))
                                }
                        }

                        if isAnswered {
                            Button(currentQuestionIndex == questions.count - 1 ? "Finish Quiz" : "Next Question") {
                                moveToNextQuestion()
                            }
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("\(topic) - Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .scrollIndicators(.visible)
    }

    // Moves to the next question or completes the quiz
    private func moveToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            isAnswered = false
            showExplanation = false
        } else {
            quizCompleted = true
            userProgressManager.recordQuizCompletion(topic: topic, total: questions.count, score: score)
        }
    }

    // Restarts the quiz from the beginning
    private func restartQuiz() {
        quizCompleted = false
        currentQuestionIndex = 0
        selectedAnswer = nil
        isAnswered = false
        score = 0
    }

    // Provides haptic feedback when an answer is selected
    private func provideHapticFeedback(isCorrect: Bool) {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.prepare()

        if isCorrect {
            feedbackGenerator.notificationOccurred(.success) // Vibrates for correct answer
        } else {
            feedbackGenerator.notificationOccurred(.error) // Vibrates for wrong answer
        }
    }

    // Handles correct/incorrect answer highlighting
    private func buttonBackground(for option: String, correctAnswer: String) -> Color {
        if isAnswered {
            if option == correctAnswer {
                return Color.green
            } else if option == selectedAnswer {
                return Color.red
            }
        }
        return Color.gray
    }
}

