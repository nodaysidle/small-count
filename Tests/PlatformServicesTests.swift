import Testing
@testable import SmallCount

@Suite("TASK-002 Platform service boundaries")
struct PlatformServicesTests {
    @Test("all required platform capabilities are represented")
    func requiredCapabilities() {
        #expect(PlatformServices.requiredCapabilities == ["Local time", "Structured persistence", "User-selected file export"])
    }
}
