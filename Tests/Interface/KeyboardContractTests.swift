import Foundation
import Testing
@testable import SmallCount

@Suite("UIR-001 keyboard")
struct KeyboardContractTests {
    @Test("arrow movement selects adjacent counters and clamps at the ends")
    func arrowNavigation() {
        let first = UUID()
        let second = UUID()
        let identifiers = [first, second]

        #expect(KeyboardContract.nextSelection(current: nil, direction: .down, identifiers: identifiers) == first)
        #expect(KeyboardContract.nextSelection(current: first, direction: .down, identifiers: identifiers) == second)
        #expect(KeyboardContract.nextSelection(current: second, direction: .down, identifiers: identifiers) == second)
        #expect(KeyboardContract.nextSelection(current: second, direction: .up, identifiers: identifiers) == first)
        #expect(KeyboardContract.settingsShortcut == ",")
    }
}
