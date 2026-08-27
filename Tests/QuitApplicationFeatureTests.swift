import Testing
@testable import SmallCount

@Suite("TASK-013 F-011 Quit Application")
struct QuitApplicationFeatureTests {
    @Test("requests ordinary termination")
    @MainActor
    func quits() async throws {
        var quitRequested = false
        let feature = QuitApplicationFeature { quitRequested = true }
        try await feature.quitApplication()
        #expect(quitRequested)
    }
}
