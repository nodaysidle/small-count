import Foundation

// MOD-005 · COMP-005 · FLOW-005 · OP-005 · F-005
@MainActor
struct ArchiveCounterFeature {
    let store: SmallCountStore

    func archiveCounter(id: UUID) async throws -> Counter {
        try await store.transact { snapshot in
            guard let index = snapshot.counters.firstIndex(where: { $0.id == id }) else {
                throw SmallCountError.counterNotFound
            }
            snapshot.counters[index].archived = true
            return snapshot.counters[index]
        }
    }
}
