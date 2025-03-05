
// accessing offline Json file to load questions

import Foundation

class QuestionLoader: ObservableObject {
    @Published var questions: [Question] = []

    init() {
        loadQuestions()
    }
    
    func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            print("Error: Could not find questions.json in bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedQuestions = try JSONDecoder().decode([Question].self, from: data)
            DispatchQueue.main.async {
                self.questions = decodedQuestions.shuffled()
            }
        } catch {
            print("Error loading revision cards: \(error.localizedDescription)")
        }
    }

}
