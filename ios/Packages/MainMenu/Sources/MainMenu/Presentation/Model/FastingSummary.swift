//
//  FastingSummary.swift
//  Nutrition
//

/// The mock fasting summary shown on the Nutrition screen (placeholder until
/// the fasting data source lands).
///
/// Shaped like the future model so only the data source has to change: the
/// timer is a preformatted label for now rather than a live clock.
public struct FastingSummary {
    public let percentComplete: Int
    public let timer: String
    public let startLabel: String
    public let endLabel: String
    public let phaseTitle: String
    public let phaseSubtitle: String

    public init(
        percentComplete: Int = 50,
        timer: String = "10:01:33",
        startLabel: String = "Yesterday 19:39",
        endLabel: String = "Today 15:39",
        phaseTitle: String = "New Phase!",
        phaseSubtitle: String = "Your metabolism is shifting gears."
    ) {
        self.percentComplete = percentComplete
        self.timer = timer
        self.startLabel = startLabel
        self.endLabel = endLabel
        self.phaseTitle = phaseTitle
        self.phaseSubtitle = phaseSubtitle
    }
}
