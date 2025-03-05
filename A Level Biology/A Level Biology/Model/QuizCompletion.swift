
// Recording quiz completion details to save user progress

import Foundation

struct QuizCompletion: Codable {
    var score: Int
    var totalQuestions: Int 
    var timestamp: Date
}
