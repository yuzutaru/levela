//
//  LevelaRootView.swift
//  Levela
//
//  Created by Yustar Pramudana on 01/10/26.
//

import Design
import Splash
import SwiftUI

/// The app shell. Owns navigation and theming; feature modules provide destinations.
struct LevelaRootView: View {
    var body: some View {
        NavigationStack {
            // The splash is the app's launch screen. It reports completion
            // through `onFinished`; navigation (e.g. to the Onboarding package)
            // will be wired here later.
            SplashView(icon: Image("SplashIcon"))
        }
        .levelaTheme()
    }
}

#Preview {
    LevelaRootView()
}
