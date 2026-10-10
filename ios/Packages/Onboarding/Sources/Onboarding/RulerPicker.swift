import Design
import SwiftUI

/// A draggable, snapping ruler used by the onboarding value cards.
///
/// The value under the fixed centre marker is reported through `onValueChange`
/// live while dragging and re-committed, snapped to `step`, on release. The
/// ruler resets its scroll position whenever the scale (`rangeStart` /
/// `rangeEnd` / `step`) changes, e.g. when the unit is switched.
public struct RulerPicker: View {
    private let value: Int
    private let rangeStart: Int
    private let rangeEnd: Int
    private let step: Int
    private let tickSpacing: CGFloat
    private let majorEvery: Int
    private let labelFormatter: (Int) -> String
    private let activeColor: Color
    private let accentColor: Color
    private let tickColor: Color
    private let labelColor: Color
    private let onValueChange: (Int) -> Void

    @State private var position: CGFloat
    @State private var lastTranslation: CGFloat = 0

    public init(
        value: Int,
        rangeStart: Int,
        rangeEnd: Int,
        step: Int,
        tickSpacing: CGFloat = 14,
        majorEvery: Int = 10,
        labelFormatter: @escaping (Int) -> String = { "\($0)" },
        activeColor: Color = OnboardingTokens.rulerAccent,
        accentColor: Color = OnboardingTokens.cardWeightAccent,
        tickColor: Color = OnboardingTokens.rulerTick,
        labelColor: Color = OnboardingTokens.rulerLabel,
        onValueChange: @escaping (Int) -> Void
    ) {
        self.value = value
        self.rangeStart = rangeStart
        self.rangeEnd = rangeEnd
        self.step = step
        self.tickSpacing = tickSpacing
        self.majorEvery = majorEvery
        self.labelFormatter = labelFormatter
        self.activeColor = activeColor
        self.accentColor = accentColor
        self.tickColor = tickColor
        self.labelColor = labelColor
        self.onValueChange = onValueChange
        _position = State(initialValue: CGFloat(value - rangeStart) / CGFloat(step))
    }

    private var tickCount: Int { max((rangeEnd - rangeStart) / step, 1) }

    public var body: some View {
        Canvas { context, size in
            draw(in: &context, size: size)
        }
        .frame(height: 78)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    let delta = gesture.translation.width - lastTranslation
                    lastTranslation = gesture.translation.width
                    position = min(max(position - delta / tickSpacing, 0), CGFloat(tickCount))
                    onValueChange(rangeStart + Int(position.rounded()) * step)
                }
                .onEnded { _ in
                    lastTranslation = 0
                    position = min(max(position.rounded(), 0), CGFloat(tickCount))
                    onValueChange(rangeStart + Int(position) * step)
                }
        )
        .onChange(of: rangeStart) { _, newStart in
            position = CGFloat(value - newStart) / CGFloat(step)
        }
    }

    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let baseline = size.height * 0.62
        let translate = centerX - (position * tickSpacing + tickSpacing / 2)

        // Soft accent highlight behind the centre.
        let band: CGFloat = 48
        let bandRect = CGRect(x: centerX - band / 2, y: 4, width: band, height: size.height - 8)
        context.fill(
            Path(roundedRect: bandRect, cornerRadius: band / 2),
            with: .color(accentColor.opacity(0.55))
        )

        let selected = min(max(Int(position.rounded()), 0), tickCount)

        for index in 0...tickCount {
            let x = CGFloat(index) * tickSpacing + tickSpacing / 2 + translate
            if x < -tickSpacing || x > size.width + tickSpacing { continue }

            let tickValue = rangeStart + index * step
            let isMajor = tickValue % majorEvery == 0
            let isCenter = index == selected
            let height: CGFloat = isCenter ? 34 : (isMajor ? 22 : 12)

            var tick = Path()
            tick.move(to: CGPoint(x: x, y: baseline - height))
            tick.addLine(to: CGPoint(x: x, y: baseline))
            context.stroke(
                tick,
                with: .color(isCenter ? activeColor : tickColor),
                lineWidth: isCenter ? 2 : 1
            )

            if isMajor || isCenter {
                let label = Text(labelFormatter(tickValue))
                    .font(LevelaTypography.labelSmall)
                    .foregroundStyle(isCenter ? activeColor : labelColor)
                context.draw(label, at: CGPoint(x: x, y: baseline + 8), anchor: .top)
            }
        }

        // Fixed centre marker.
        var marker = Path()
        marker.move(to: CGPoint(x: centerX, y: baseline - 42))
        marker.addLine(to: CGPoint(x: centerX, y: baseline + 2))
        context.stroke(marker, with: .color(activeColor), lineWidth: 2)
    }
}
