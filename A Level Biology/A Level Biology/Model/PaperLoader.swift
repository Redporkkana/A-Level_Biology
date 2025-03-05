

// Access to JSON file (online or offline)

import Foundation

class PaperLoader: ObservableObject {
    @Published var papers: [Paper] = []
    
    let jsonURL = URL(string: "https://gist.githubusercontent.com/Redporkkana/16c7247ea0b52e6bafa08c621aa9941f/raw/4fc177c642d0d8c1f50738312838c6efdd6c8376/papers.json?\(UUID().uuidString)")!
    
    init() {
        loadPapers()
    }
    
    func loadPapers() {
        URLSession.shared.dataTask(with: jsonURL) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Error: No data received")
                return
            }

            do {
                let decodedPapers = try JSONDecoder().decode([Paper].self, from: data)
                DispatchQueue.main.async {
                    self.papers = decodedPapers.shuffled() // Shuffle if needed
                }
                print("Successfully fetched \(decodedPapers.count) keywords from GitHub Gist")
            } catch {
                print("JSON Decoding Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
