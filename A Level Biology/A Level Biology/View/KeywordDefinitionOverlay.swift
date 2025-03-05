
// Overlay with keyword definition

import SwiftUI

struct KeywordDefinitionOverlay: View {
    let keyword: Keyword
    @Binding var showDefinition: Bool

    var body: some View {
        VStack {
            Text(keyword.keyword)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top)

            Text(keyword.definition)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()

        }
        .frame(width: 300)
        .padding()
        .background(Color.black)
        .cornerRadius(15)
        .shadow(radius: 5)
        .overlay(
            Button(action: {
                showDefinition = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(10)
            },
            alignment: .topTrailing
        )
        .transition(.scale)
    }
}
