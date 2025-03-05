
// Object model for Question

import Foundation

struct Question: Codable, Identifiable {
    let id: String
    let topic: String // filtering questions by topic
    let subtopic: String
    let question: String
    let image_url: String?
    let options: [String]
    let correctAnswer: String
    let explanation: String
}


