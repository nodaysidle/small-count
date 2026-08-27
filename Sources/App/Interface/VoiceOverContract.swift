enum VoiceOverContract {
    static func counterLabel(name: String, total: Int) -> String { "\(name), \(total) today" }
    static let retryLabel = "Retry the failed operation"
}
