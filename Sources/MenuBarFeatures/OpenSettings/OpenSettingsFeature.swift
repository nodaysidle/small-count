// MOD-010 · COMP-010 · FLOW-010 · OP-010 · F-010
@MainActor
struct OpenSettingsFeature {
    private let presentSettings: @MainActor () async throws -> Void

    init(presentSettings: @escaping @MainActor () async throws -> Void) {
        self.presentSettings = presentSettings
    }

    func openSettings() async throws {
        try Task.checkCancellation()
        try await presentSettings()
    }
}
