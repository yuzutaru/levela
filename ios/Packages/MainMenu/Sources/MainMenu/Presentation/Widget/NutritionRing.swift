//
//  NutritionRing.swift
//  MainMenu
//

import Design
import SwiftUI

/// The progress ring: one arc per macro, sized by that macro's share of the
/// total grams consumed, so the three arcs close the circle.
struct NutritionRing: View {
    private static let ringDiameter: CGFloat = 92
    private static let ringStroke: CGFloat = 12

    let summary: NutritionSummary

    private var arcs: [RingArc] {
        let total = max(summary.macros.reduce(0) { $0 + $1.consumed }, 1)
        var start: CGFloat = 0
        var result: [RingArc] = []
        for macro in summary.macros {
            let end = start + CGFloat(macro.consumed) / CGFloat(total)
            result.append(RingArc(start: start, end: end, color: macro.color))
            start = end
        }
        return result
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray200, lineWidth: Self.ringStroke)

            ForEach(Array(arcs.enumerated()), id: \.offset) { _, arc in
                Circle()
                    .trim(from: arc.start, to: arc.end)
                    .stroke(arc.color, style: StrokeStyle(lineWidth: Self.ringStroke, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }

            VStack(spacing: 1) {
                Text(summary.dayLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.gray500)
                Text("\(summary.percentComplete)%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.navy900)
                Text("+\(summary.deltaPercent)%")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.green500)
            }
        }
        .frame(width: Self.ringDiameter, height: Self.ringDiameter)
    }
}

struct RingArc {
    let start: CGFloat
    let end: CGFloat
    let color: Color
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.white, .lightBlue100],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        RadialGradient(
            colors: [.lightBlue300.opacity(0.55), .clear],
            center: UnitPoint(x: 0.5, y: -0.08),
            startRadius: 0,
            endRadius: 460
        )
        .ignoresSafeArea()

        NutritionRing(summary: NutritionSummary())
            .frame(width: 124, height: 124)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 14, y: 6)
    }
    .levelaTheme()
}
