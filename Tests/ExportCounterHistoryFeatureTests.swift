import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-011 F-009 Export Counter History")
struct ExportCounterHistoryFeatureTests {
    @Test("writes only the selected aggregate to destination")
    @MainActor
    func exportsSelectedAggregate() async throws {
        let selected = Counter(name: "Selected", color: nil)
        let other = Counter(name: "Other", color: nil)
        let event = Event(occurredAt: .now, counterID: selected.id)
        let persistence = TestPersistence(snapshot: .init(schemaVersion: 1, counters: [selected, other], events: [event]))
        let store = SmallCountStore(persistence: persistence)
        try await store.restore()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("md")
        defer { try? FileManager.default.removeItem(at: url) }
        let result = try await ExportCounterHistoryFeature(store: store).exportCounterHistory(selectionID: selected.id, destination: url)
        let text = try String(contentsOf: result, encoding: .utf8)
        #expect(text.contains("Selected"))
        #expect(!text.contains("Other"))
        #expect(store.snapshot.counters.count == 2)
    }
}
