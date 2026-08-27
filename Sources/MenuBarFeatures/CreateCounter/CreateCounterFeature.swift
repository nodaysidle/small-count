import Foundation

// MOD-001 · COMP-001 · FLOW-001 · OP-001 · F-001
@MainActor
struct CreateCounterFeature {
    let store: SmallCountStore

    func createCounter(draft: CounterDraft) async throws -> Counter {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw SmallCountError.emptyName }
        let counter = Counter(name: name, color: draft.color, archived: false)
        return try await store.transact { snapshot in
            snapshot.counters.append(counter)
            return counter
        }
    }
}
