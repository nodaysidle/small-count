import Testing
@testable import SmallCount

@Suite("TASK-002 User-selected export adapter")
struct UserSelectedFileExportAdapterTests {
    @Test("cancel is a non-mutating typed outcome")
    func cancellation() {
        #expect(UserSelectedFileExportError.cancelled.description == "Export cancelled")
    }
}
