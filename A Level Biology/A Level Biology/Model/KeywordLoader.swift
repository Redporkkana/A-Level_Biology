
// Access to JSON file (online or offline)

import Foundation

class KeywordLoader: ObservableObject {
    @Published var keywords: [Keyword] = []

    let jsonURL = URL(string: "https://gist.githubusercontent.com/Redporkkana/46825033474c21e35d1ceb671ddff0eb/raw/fbc681fccb8003b8af79c7de7583c36ec99962bc/keywords.json?\(UUID().uuidString)")! // Gist raw URL

    init() {
        loadKeywords()
    }

    func loadKeywords() {
        guard let url = Bundle.main.url(forResource: "keywords", withExtension: "json") else {
            print("Error: Could not find questions.json in bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedKeywords = try JSONDecoder().decode([Keyword].self, from: data)
            DispatchQueue.main.async {
                self.keywords = decodedKeywords.shuffled()
            }
        } catch {
            print("Error loading keywords: \(error.localizedDescription)")
        }
    }
}

