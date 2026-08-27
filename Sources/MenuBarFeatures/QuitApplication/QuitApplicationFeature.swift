// MOD-011 · COMP-011 · FLOW-011 · OP-011 · F-011
@MainActor
struct QuitApplicationFeature {
    private let requestTermination: @MainActor () async throws -> Void

    init(requestTermination: @escaping @MainActor () async throws -> Void) {
        self.requestTermination = requestTermination
    }

    func quitApplication() async throws {
        try Task.checkCancellation()
        try await requestTermination()
    }
}
