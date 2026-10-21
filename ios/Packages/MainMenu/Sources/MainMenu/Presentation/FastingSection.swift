//
//  FastingSection.swift
//  MainMenu
//

import Design
import SwiftUI

/// The fasting view: the phase banner, the fasting ring, the start/end times and
/// the end-fasting action.
///
/// Lives below the summary cards on the Today screen; the shared splash-style
/// background is drawn by the app shell behind the content.
///
/// Mirrors the Android `FastingSection`.
public struct FastingSection: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            PhaseBanner()
            FastingRing()
            FastingTimes()
            EndFastingButton()
        }
    }
}

#Preview {
    FastingSection()
        .padding(24)
        .levelaTheme()
}
