import Design
import SwiftUI

/// Entry point for the onboarding feature.
///
/// This is the destination the app's `NavigationStack` shows; the app never
/// reaches into the feature beyond ``OnboardingRoute`` and this view.
@MainActor
public struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.levelaColors) private var colors

    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("Welcome to Levela")
                .font(LevelaTypography.displaySmall)
                .foregroundStyle(colors.onBackground)
                .multilineTextAlignment(.center)

            Text("Page \(viewModel.currentPage + 1) of \(viewModel.pageCount)")
                .font(LevelaTypography.bodyLarge)
                .foregroundStyle(colors.onBackground.opacity(0.7))

            Spacer()

            Button(action: viewModel.advance) {
                Text(viewModel.isLastPage ? "Get started" : "Continue")
                    .font(LevelaTypography.labelLarge)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(colors.primary)
            .disabled(viewModel.isLastPage)
            .padding(.horizontal, 24)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
    }
}

#Preview {
    OnboardingView()
        .levelaTheme()
}
