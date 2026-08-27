import Foundation
import Observation

/// TASK-014 typed integration surface for every primary journey.
@MainActor
@Observable
final class PrimaryJourneys {
    private let store: SmallCountStore
    private let localTime: any LocalTimeProviding
    private let exportSelection: any UserSelectedFileExportProviding

    var snapshot: SmallCountSnapshot { store.snapshot }

    init(
        persistence: any StructuredPersistenceProviding,
        localTime: any LocalTimeProviding = LocalTimeAdapter(),
        exportSelection: any UserSelectedFileExportProviding = UserSelectedFileExportAdapter()
    ) {
        store = SmallCountStore(persistence: persistence)
        self.localTime = localTime
        self.exportSelection = exportSelection
    }

    func restore() async throws {
        try await store.restore()
    }

    func createCounter(draft: CounterDraft) async throws -> Counter {
        try await CreateCounterFeature(store: store).createCounter(draft: draft)
    }

    func editCounter(id: UUID, changes: CounterChanges) async throws -> Counter {
        try await EditCounterFeature(store: store).editCounter(id: id, changes: changes)
    }

    func recordEvent(scopeID: UUID, draft: EventDraft) async throws -> Event {
        try await RecordEventFeature(store: store, localTime: localTime)
            .recordEvent(scopeID: scopeID, draft: draft)
    }

    func viewTodaySTotals(scopeID: UUID) async throws -> ViewTodaySTotalsResult {
        try await ViewTodaySTotalsFeature(store: store, localTime: localTime)
            .viewTodaySTotals(scopeID: scopeID)
    }

    func archiveCounter(id: UUID) async throws -> Counter {
        try await ArchiveCounterFeature(store: store).archiveCounter(id: id)
    }

    func restoreCounter(id: UUID) async throws -> Counter {
        try await RestoreCounterFeature(store: store).restoreCounter(id: id)
    }

    func listActiveCounters() async throws -> [Counter] {
        try await ListActiveCountersFeature(store: store).listActiveCounters()
    }

    func listArchivedCounters() async throws -> [Counter] {
        try await ListArchivedCountersFeature(store: store).listArchivedCounters()
    }

    func exportCounterHistory(selectionID: UUID, destination: URL) async throws -> URL {
        try await ExportCounterHistoryFeature(store: store)
            .exportCounterHistory(selectionID: selectionID, destination: destination)
    }

    func exportCounterHistory(selectionID: UUID, suggestedName: String) async throws -> URL {
        let destination = try await exportSelection.selectExportDestination(suggestedName: suggestedName)
        return try await exportCounterHistory(selectionID: selectionID, destination: destination)
    }
}
