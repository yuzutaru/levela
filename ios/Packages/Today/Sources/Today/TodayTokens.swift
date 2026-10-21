/// Contract values for the Today dashboard.
///
/// Mirrors the Android `TodayTokens` and the `mainmenu.today` handle the app's
/// UI tests assert against. Keep `screenTag` stable: the routing and end-to-end
/// tests find the destination by it.
public enum TodayTokens {
    /// The Today heading copy.
    public static let title = "Overview"

    /// Stable accessibility identifier for the Today destination's heading.
    public static let screenTag = "mainmenu.today"
}
