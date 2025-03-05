
// Loading topics form json file

import Foundation

class TopicLoader: ObservableObject {
    @Published var topics: [Topic] = []

    init() {
        loadTopics()
    }

    func loadTopics() {
        guard let url = Bundle.main.url(forResource: "topics", withExtension: "json") else {
            print("Error: Could not find questions.json in bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedTopics = try JSONDecoder().decode([Topic].self, from: data)
            DispatchQueue.main.async {
                self.topics = decodedTopics.shuffled()
            }
        } catch {
            print("Error loading revision cards: \(error.localizedDescription)")
        }
    }

}

