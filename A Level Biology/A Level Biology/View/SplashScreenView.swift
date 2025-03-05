
// Splashscreen animation

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false // Tracks transition to LaunchView
    @State private var opacity = 0.2 // Controls fade-in animation

    var body: some View {
        if isActive {
            ContentView() // Show LaunchView after delay
        } else {
            VStack {
                Image(systemName: "allergens") // Example icon (replace with logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.cyan)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.5)) {
                            opacity = 1.0 // Fade-in effect
                        }
                    }

                Text("decoding life...")
                    .font(.system(.title, design: .monospaced))
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(0.5), radius: 5, x: 0, y: 0)
                    .padding(.top, 10)

                ProgressView() // Spinning loading indicator
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.top, 10)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // 3-second delay
                    isActive = true
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .ignoresSafeArea()
        }
    }
}
