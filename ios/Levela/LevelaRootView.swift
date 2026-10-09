//
//  LevelaRootView.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import Onboarding
import Splash
import SwiftUI

/// The app shell. Owns navigation and theming; feature modules provide destinations.
struct LevelaRootView: View {
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            // Splash is the launch screen; tapping "Continue as a guest"
            // reports completion and moves on to the onboarding flow with a
            // push-style slide (in from the right, splash out to the left).
            ZStack {
                if showOnboarding {
                    OnboardingView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    SplashView(icon: Image("SplashIcon")) {
                        showOnboarding = true
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showOnboarding)
        }
        .levelaTheme()
    }
}

#Preview {
    LevelaRootView()
}
