import Testing
@testable import SmallCount

@Suite("UIR-004 appearance")
struct AppearanceContractTests {
    @Test("semantic appearance and selectable counter colors are declared")
    func semanticColors() {
        #expect(AppearanceContract.usesSemanticSystemColors)
        #expect(AppearanceContract.supportedModes == ["light", "dark"])
        #expect(AppearanceContract.counterColors == ["", "blue", "red", "orange", "yellow", "green", "purple", "pink"])
    }
}
