import Testing
@testable import SmallCount

@Suite("TASK-012 F-010 Open Settings")
struct OpenSettingsFeatureTests {
    @Test("invokes the Settings scene presenter")
    @MainActor
    func opensSettings() async throws {
        var opened = false
        let feature = OpenSettingsFeature { opened = true }
        try await feature.openSettings()
        #expect(opened)
    }
}
