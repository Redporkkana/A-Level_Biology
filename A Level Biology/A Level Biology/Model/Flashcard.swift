// Object model for a Flashcard

import Foundation

struct Flashcard: Codable, Identifiable {
    let id: UUID
    let question: String
    let keywords: [String]
    let longAnswer: String
}
