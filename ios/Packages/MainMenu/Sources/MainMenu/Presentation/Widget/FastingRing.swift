//
//  FastingRing.swift
//  Nutrition
//

import Design
import Foundation
import SwiftUI

/// The fasting progress ring: an elapsed arc (green → orange) over a pale track,
/// with the current phase marked by a flame badge at the arc's leading edge. The
/// centre holds the elapsed label, the timer and a skip control.
///
/// The arc starts at the bottom and sweeps clockwise through the left half to
/// the top, matching the design. Mirrors the Android `FastingRing`.
public struct FastingRing: View {
    private static let stroke: CGFloat = 28
    private static let badgeSize: CGFloat = 72
    private static let markerSize: CGFloat = 40

    public let summary: FastingSummary

    public init(summary: FastingSummary = FastingSummary()) {
        self.summary = summary
    }

    public var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            // The ring is inset by half the stroke, so its centerline sits at
            // `size / 2 - stroke / 2` — the same radius the markers use.
            let radius = size / 2 - Self.stroke / 2
            let fraction = CGFloat(summary.percentComplete) / 100
            let startAngle: Double = 90
            // The arc sweeps clockwise from the bottom, so the leading edge is
            // at `startAngle + fraction * 360`.
            let sweepDegrees = Double(fraction) * 360
            let endAngle = startAngle + sweepDegrees

            ZStack {
                Circle()
                    .stroke(Color.gray200, lineWidth: Self.stroke)
                    .padding(Self.stroke / 2)

                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.green500, .orange300, .orange500]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(180)
                        ),
                        style: StrokeStyle(lineWidth: Self.stroke, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))
                    .padding(Self.stroke / 2)

                RingMarker(angle: 150, radius: radius, size: Self.markerSize, center: center) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.pink500)
                }

                RingMarker(angle: -55, radius: radius, size: Self.markerSize, center: center) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.gray400)
                }

                RingMarker(angle: 45, radius: radius, size: Self.markerSize, center: center) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.gray400)
                }

                RingMarker(
                    angle: endAngle,
                    radius: radius,
                    size: Self.badgeSize,
                    center: center,
                    borderColor: .orange500,
                    borderWidth: 4
                ) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.orange500)
                }

                VStack(spacing: 8) {
                    Text("Elapsed time (\(summary.percentComplete)%)")
                        .font(LevelaTypography.bodyLarge)
                        .foregroundStyle(Color.gray500)

                    Text(summary.timer)
                        .font(LevelaFontFamily.poppins.font(.bold, size: 44, relativeTo: .largeTitle))
                        .foregroundStyle(Color.navy900)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Image(systemName: "forward.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.gray500)
                        .frame(width: 52, height: 52)
                        .background(Color.gray100)
                        .clipShape(Circle())
                }
                .frame(maxWidth: size * 0.62)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// Places `content` on the ring's circumference at `angle` (0° = 3 o'clock).
private struct RingMarker<Content: View>: View {
    let angle: Double
    let radius: CGFloat
    let size: CGFloat
    let center: CGPoint
    let borderColor: Color
    let borderWidth: CGFloat
    let content: Content

    init(
        angle: Double,
        radius: CGFloat,
        size: CGFloat,
        center: CGPoint,
        borderColor: Color = .gray200,
        borderWidth: CGFloat = 1,
        @ViewBuilder content: () -> Content
    ) {
        self.angle = angle
        self.radius = radius
        self.size = size
        self.center = center
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.content = content()
    }

    var body: some View {
        let radians = angle * .pi / 180
        let point = CGPoint(
            x: center.x + radius * cos(radians),
            y: center.y + radius * sin(radians)
        )

        content
            .frame(width: size, height: size)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(borderColor, lineWidth: borderWidth))
            .position(point)
    }
}

#Preview {
    FastingRing()
        .padding(24)
        .levelaTheme()
}
