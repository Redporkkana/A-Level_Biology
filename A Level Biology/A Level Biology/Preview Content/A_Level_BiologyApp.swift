//
//  A_Level_BiologyApp
//  A Level Biology
//
//  Created by Easy Business Cloud on 04/02/2025.
//

import SwiftUI
import FirebaseCore


@main
struct A_Level_BiologyApp: App {
    
    @StateObject private var authViewModel = AuthViewModel() // ✅ Make sure it exists!
    @StateObject private var userProgressManager = UserProgressManager()
    init() {
            FirebaseApp.configure()
        }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}

