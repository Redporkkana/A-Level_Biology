// Object model for saving user progress in various aspects

import Foundation

class UserProgress: ObservableObject, Codable {
    @Published var completedQuizzesWithTimestamps: [String: QuizCompletion]
    @Published var lastCompletedQuiz: String?
    
    @Published var weakTopics: [String]
    
    @Published var flashcards: [Flashcard] {
        didSet {
            saveProgress()
        }
    }
    @Published var completedGapFills: [String: Set<String>] = [:]
    
    @Published var completedPapers: [String: Int] = [:] // Paper ID → Match %

    // Explicit initializer
    init(completedQuizzesWithTimestamps: [String: QuizCompletion] = [:],
         lastCompletedQuiz: String? = nil,
         weakTopics: [String] = [],
         flashcards: [Flashcard] = [],
         completedPapers: [String: Int] = [:]) { // Include completed papers
        self.completedQuizzesWithTimestamps = completedQuizzesWithTimestamps
        self.lastCompletedQuiz = lastCompletedQuiz
        self.weakTopics = weakTopics
        self.flashcards = flashcards
        self.completedPapers = completedPapers
    }

    // Updated CodingKeys to include completedPapers
    enum CodingKeys: String, CodingKey {
        case completedQuizzesWithTimestamps
        case lastCompletedQuiz
        case weakTopics
        case flashcards
        case completedPapers
    }

    // Required for Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.completedQuizzesWithTimestamps = try container.decode([String: QuizCompletion].self, forKey: .completedQuizzesWithTimestamps)
        self.lastCompletedQuiz = try container.decodeIfPresent(String.self, forKey: .lastCompletedQuiz)
        self.weakTopics = try container.decode([String].self, forKey: .weakTopics)
        self.flashcards = try container.decode([Flashcard].self, forKey: .flashcards)
        self.completedPapers = try container.decode([String: Int].self, forKey: .completedPapers) //  Decode completed papers
    }

    // Required for Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(completedQuizzesWithTimestamps, forKey: .completedQuizzesWithTimestamps)
        try container.encodeIfPresent(lastCompletedQuiz, forKey: .lastCompletedQuiz)
        try container.encode(weakTopics, forKey: .weakTopics)
        try container.encode(flashcards, forKey: .flashcards)
        try container.encode(completedPapers, forKey: .completedPapers) //  Encode completed papers
    }

    func recordPaperCompletion(paperID: String, matchPercentage: Int) {
        DispatchQueue.main.async {
            self.completedPapers[paperID] = matchPercentage
            self.saveProgress()
            print(" Paper \(paperID) completed with \(matchPercentage)% match")
        }
    }

    func resetPaperProgress() {
        DispatchQueue.main.async {
            self.completedPapers.removeAll()
            self.saveProgress()
            print(" Paper progress has been reset")
        }
    }


    // Save user progress to UserDefaults
    private func saveProgress() {
        if let encodedData = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encodedData, forKey: "UserProgress")
        }
    }
}
