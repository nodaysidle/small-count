import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-014 Primary journeys")
struct PrimaryJourneyTests {
    @Test("create, record, total, archive, and restore flow through typed operations")
    @MainActor
    func completeJourney() async throws {
        let instant = Date(timeIntervalSince1970: 1_700_000_000)
        let persistence = TestPersistence()
        let journeys = PrimaryJourneys(
            persistence: persistence,
            localTime: FixedLocalTime(instant: instant, zone: .gmt)
        )
        try await journeys.restore()
        let counter = try await journeys.createCounter(draft: .init(name: "Water", color: "blue"))
        _ = try await journeys.recordEvent(scopeID: counter.id, draft: EventDraft())
        #expect(try await journeys.viewTodaySTotals(scopeID: counter.id).total == 1)
        _ = try await journeys.archiveCounter(id: counter.id)
        #expect(try await journeys.listActiveCounters().isEmpty)
        _ = try await journeys.restoreCounter(id: counter.id)
        #expect(try await journeys.listActiveCounters().map(\.id) == [counter.id])
    }

    @Test("export destination selection stays behind the typed journey boundary")
    @MainActor
    func exportBoundary() async throws {
        let counter = Counter(name: "Water", color: "blue")
        let persistence = TestPersistence(
            snapshot: SmallCountSnapshot(schemaVersion: 1, counters: [counter], events: [])
        )
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("md")
        let selection = TestExportSelection(destination: destination)
        let journeys = PrimaryJourneys(persistence: persistence, exportSelection: selection)
        try await journeys.restore()

        let result = try await journeys.exportCounterHistory(
            selectionID: counter.id,
            suggestedName: "Water-history.md"
        )

        #expect(selection.suggestedNames == ["Water-history.md"])
        #expect(result == destination)
        try? FileManager.default.removeItem(at: destination)
    }
}
