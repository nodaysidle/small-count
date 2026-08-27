import Foundation

// MOD-009 · COMP-009 · FLOW-009 · OP-009 · F-009
@MainActor
struct ExportCounterHistoryFeature {
    let store: SmallCountStore
    private let exporter = ExportCounterHistoryMarkdownExport()

    func exportCounterHistory(selectionID: UUID, destination: URL) async throws -> URL {
        guard let counter = store.snapshot.counters.first(where: { $0.id == selectionID }) else {
            throw SmallCountError.counterNotFound
        }
        let aggregate = SmallCountSnapshot(
            schemaVersion: store.snapshot.schemaVersion,
            counters: [counter],
            events: store.snapshot.events.filter { $0.counterID == selectionID }
        )
        let data = try exporter.data(for: aggregate)
        try Task.checkCancellation()
        do {
            try data.write(to: destination, options: .atomic)
            return destination
        } catch {
            throw SmallCountError.exportFailed(error.localizedDescription)
        }
    }
}
