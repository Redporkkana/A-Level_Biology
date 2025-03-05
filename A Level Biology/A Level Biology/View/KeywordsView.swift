
// Display keywords in Keyword section


 import SwiftUI
 
 struct KeywordsView: View {
     @ObservedObject var keywordLoader = KeywordLoader()
 
     @State private var selectedKeyword: Keyword?
     @State private var showDefinition = false
 
     var body: some View {
         ScrollView {
             VStack(spacing: 20) {
                 Text("Biology Keywords")
                     .font(.system(.title2, design: .monospaced))
                     .fontWeight(.bold)
                     .padding()
 
                 if keywordLoader.keywords.isEmpty {
                     Text("No keywords available.")
                         .foregroundColor(.gray)
                         .padding()
                 } else {
                     LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))], spacing: 20) {
                         ForEach(keywordLoader.keywords) { keyword in //
                             KeywordButtonView(
                                keyword: keyword,
                                selectedKeyword: $selectedKeyword,
                                showDefinition: $showDefinition
                             )
                         }
                     }
                     .padding()
                 }
             }
         }
         .padding(.bottom, 20)
         .background(Color(.systemBackground))
         .overlay(
            Group {
                if showDefinition, let keyword = selectedKeyword {
                    KeywordDefinitionOverlay(keyword: keyword, showDefinition: $showDefinition)
                }
            }
         )
         .onAppear {
             keywordLoader.loadKeywords()
         }
     }
}
 
