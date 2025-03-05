
// Object model for past papers 

import Foundation

struct Paper: Codable, Identifiable {
    let id: String
    let assignment: String // The question prompt
    let concepts: [String] // The pool of matches for correct answer
    let possibleAnswer: String
}

