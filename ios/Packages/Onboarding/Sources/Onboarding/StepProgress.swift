import SwiftUI

/// The segmented step indicator at the top of the onboarding flow: one segment
/// per step, completed/current segments filled with the active colour.
public struct StepProgress: View {
    private let current: Int
    private let count: Int

    public init(current: Int, count: Int) {
        self.current = current
        self.count = count
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? OnboardingTokens.activeSegment : OnboardingTokens.inactiveSegment)
                    .frame(width: 32, height: 4)
            }
        }
    }
}
