import Foundation
import Testing
@testable import SmallCount

@Suite("INV-001 reversibleState")
struct Invariant001Tests {
    @Test("archive transitions preserve counter and events")
    func reversibleState() {
        let id = UUID()
        let event = Event(id: UUID(), occurredAt: .now, counterID: id)
        var snapshot = SmallCountSnapshot(schemaVersion: 1, counters: [.init(id: id, name: "A", color: nil, archived: false)], events: [event])
        snapshot.counters[0].archived = true
        snapshot.counters[0].archived = false
        #expect(snapshot.counters[0].id == id)
        #expect(snapshot.events == [event])
    }
}
