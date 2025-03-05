// User progress saving and retrieving functionality

import Foundation

class UserProgressManager: ObservableObject {
    @Published var progress = UserProgress()

    init() {
        loadProgress()
    }

    func saveProgress() {
        DispatchQueue.global(qos: .background).async {
            if let encodedData = try? JSONEncoder().encode(self.progress) {
                UserDefaults.standard.set(encodedData, forKey: "UserProgress")
                print("Progress saved")
            }
        }
    }

    func loadProgress() {
        if let savedData = UserDefaults.standard.data(forKey: "UserProgress"),
           let decodedProgress = try? JSONDecoder().decode(UserProgress.self, from: savedData) {
            DispatchQueue.main.async {
                self.progress = decodedProgress
                print("DEBUG: Loaded progress with \(self.progress.completedPapers.count) completed papers.")
            }
        } else {
            print("DEBUG: No saved progress found, initializing new progress.")
            self.progress = UserProgress()
        }
    }


    func recordQuizCompletion(topic: String, total: Int, score: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let timestamp = Date()
            let quizCompletion = QuizCompletion(score: score, totalQuestions: total, timestamp: timestamp)

            // Now we can modify properties directly (since it's a class)
            self.progress.completedQuizzesWithTimestamps[topic] = quizCompletion
            self.progress.lastCompletedQuiz = topic
            

            // Track weak topics
            if (Double(score)/Double(total) < 0.7) {
                if !self.progress.weakTopics.contains(topic) {
                    self.progress.weakTopics.append(topic)
                }
            } else {
                self.progress.weakTopics.removeAll { $0 == topic }
            }

            self.saveProgress()
        }
    }
    
    func addFlashcard(question: String, keywords: [String], longAnswer: String) {
        DispatchQueue.main.async {
            let newFlashcard = Flashcard(id: UUID(), question: question, keywords: keywords, longAnswer: longAnswer)
            if !self.progress.flashcards.contains(where: { $0.question == newFlashcard.question}) {
                self.progress.flashcards.append(newFlashcard)
                self.objectWillChange.send()
            }
                
        }
    }
    
    func recordPaperCompletion(paperID: String, matchPercentage: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.progress.completedPapers[paperID] = matchPercentage
            self.saveProgress()
            self.objectWillChange.send()
            print("Paper \(paperID) recorded.")
        }
    }

    // Removing a flashcard from LaunchView
    
    func removeFlashcard(id: UUID) {
        DispatchQueue.main.async {
            self.progress.flashcards.removeAll { $0.id == id }
            self.objectWillChange.send()
        }
    }
    
    // Reset progress for past paper completion
    func resetPaperCompletion() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.progress.completedPapers.removeAll()
            self.saveProgress()
            self.objectWillChange.send()
            print("All paper completions have been reset.")
        }
    }

}

