
// Past paper questions and answers with input assessment by means of NLP

import SwiftUI
import NaturalLanguage

struct PaperView: View {
    @EnvironmentObject var userProgressManager: UserProgressManager
    @StateObject private var paperLoader = PaperLoader()

    @State private var currentPaper: Paper?
    @State private var userInput: String = ""
    @State private var showAnswer = false
    @State private var aiFeedback: String = ""
    @State private var similarityScore: Double = 0.0

    // Get completed papers from UserProgressManager
    var completedPapers: Set<String> {
        return Set(userProgressManager.progress.completedPapers.keys)
    }

    // Check if all papers have been completed
    var allPapersCompleted: Bool {
        return completedPapers.count == paperLoader.papers.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if allPapersCompleted {
                    Text("🎉 You've completed all papers! 🎉")
                        .font(.title)
                        .foregroundColor(.green)
                        .padding()

                    // "Retry All Papers" button
                    Button("Retry all papers") {
                        userProgressManager.resetPaperCompletion()
                    }
                    .font(.system(.callout, design: .monospaced))
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(colors: [.red, .indigo], startPoint: .top, endPoint: .bottom))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                } else if let paper = currentPaper {
                    Text("Question")
                        .font(.title2)
                        .bold()

                    Text(paper.assignment)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))

                    if !showAnswer {
                        TextField("Type your answer here...", text: $userInput)
                            .frame(height: 50)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                            .disableAutocorrection(false)
                        Button("Check my answer") {
                            checkAnswerWithAI(userInput: userInput, correctAnswers: paper.concepts)
                            showAnswer = true
                        }
                        .font(.system(.callout, design: .monospaced))
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.mint, .cyan], startPoint: .top, endPoint: .bottom))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        Button("Try another question") {
                                loadNewPaper()
                                showAnswer = false
                                userInput = ""
                                aiFeedback = ""
                                similarityScore = 0.0
                        }
                        .font(.system(.callout, design: .monospaced))
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(colors: [.cyan, .mint], startPoint: .top, endPoint: .bottom))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    if showAnswer {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Answer:")
                                .font(.headline)
                                .foregroundColor(.mint)

                            Text(userInput.isEmpty ? "No answer provided." : userInput)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cornerRadius(8)

                            Text("Automatic feedback:")
                                .font(.headline)
                                .foregroundColor(.purple)

                            Text(aiFeedback)
                                .font(.system(.callout, design: .monospaced))
                                .foregroundColor(similarityScore > 0.75 ? .green : .orange)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cornerRadius(8)
                            
                            Text("Key concepts:")
                                .font(.headline)

                            VStack {
                                ForEach(paper.concepts, id: \.self) { word in
                                    Text(word)
                                        .foregroundColor(.white)
                                        .font(.system(.callout, design: .monospaced))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .shadow(radius: 5)
                                        .background(Capsule().fill(LinearGradient(colors: [.cyan, .blue], startPoint: .bottom, endPoint: .top)))
                                }
                            }
                            .padding()
                            
                            Text("Long Answer:")
                                .font(.headline)
                                .foregroundColor(.mint)
                            
                            ScrollView {
                                Text(paper.possibleAnswer)
                                    .font(.system(.callout, design: .monospaced))
                                    .shadow(radius: 5)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .cornerRadius(8)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxHeight: 450)
                            
                            Button("Try another question") {
                                    userProgressManager.recordPaperCompletion(
                                            paperID: paper.id,
                                            matchPercentage: Int(similarityScore * 100))
                                    loadNewPaper()
                                    showAnswer = false
                                    userInput = ""
                                    aiFeedback = ""
                                    similarityScore = 0.0
                            }
                            .font(.system(.callout, design: .monospaced))
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: [.cyan, .mint], startPoint: .top, endPoint: .bottom))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                                
                        }
                        .padding()
                    }
                    
                } else {
                    Text("...")
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        loadNewPaper()
                                    }
                        }
                }

            }
            .padding()
            .navigationTitle("Paper Review")
            /*.onAppear {
                userProgressManager.resetPaperCompletion()
            }*/
        }
    }
    
    private func loadNewPaper() {
        let remainingPapers = paperLoader.papers.filter { !completedPapers.contains($0.id) }
        if let nextPaper = remainingPapers.randomElement() {
            currentPaper = nextPaper
        } else {
            currentPaper = nil
        }
    }
    private func checkAnswerWithAI(userInput: String, correctAnswers: [String]) {
        let userAnswerTokens = Set(tokenize(text: userInput))

        // Step 1: Check for an exact or strong match with any concept
        for concept in correctAnswers {
            let conceptTokens = Set(tokenize(text: concept))
            
            // If at least one word from the concept is in the user's answer, give full credit
            if !userAnswerTokens.isDisjoint(with: conceptTokens) {
                similarityScore = 1.0 // Full match found!
                aiFeedback = "Excellent! Your answer is very accurate and covers a key concept."
                return // No need to check further
            }
        }

        // Step 2: If no exact matches, compute partial similarity
        var maxSimilarity: Double = 0.0

        for concept in correctAnswers {
            let conceptTokens = Set(tokenize(text: concept))
            let intersection = userAnswerTokens.intersection(conceptTokens)
            
            let similarity = Double(intersection.count) / Double(conceptTokens.count)
            
            if similarity > maxSimilarity {
                maxSimilarity = similarity
            }
        }

        similarityScore = maxSimilarity

        // AI Feedback based on similarity score
        if maxSimilarity > 0.8 {
            aiFeedback = "Great job! Your answer is close to a key concept."
        } else if maxSimilarity > 0.5 {
            aiFeedback = "Good attempt! You included some key points, but consider elaborating further."
        } else {
            aiFeedback = "Your answer needs more details. Try to include key concepts such as: \(correctAnswers.joined(separator: ", "))"
        }
    }

    // Tokenization Function (Apple NLP)
      private func tokenize(text: String) -> [String] {
          let tokenizer = NLTokenizer(unit: .word)
          tokenizer.string = text.lowercased()
          var words: [String] = []
          
          tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
              words.append(String(text[tokenRange]))
              return true
          }
          
          return words.filter { !$0.isEmpty }
      }
}

