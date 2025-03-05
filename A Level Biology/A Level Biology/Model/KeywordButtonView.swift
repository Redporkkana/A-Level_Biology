// Formatted button for displaying keywords

import SwiftUI

struct KeywordButtonView: View {
    let keyword: Keyword // Receives full Keyword object
    @Binding var selectedKeyword: Keyword? // Tracks selected keyword
    @Binding var showDefinition: Bool // Controls overlay visibility

    var body: some View {
        Button(action: {
            selectedKeyword = keyword
            showDefinition = true
        }) {
            VStack {
                Text(keyword.keyword) // Display only the term on the keyword card
                    .font(.headline)
                    .minimumScaleFactor(0.7)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottom))
            )
            .shadow(radius: 2)
        }
    }
}
