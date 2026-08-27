// MOD-007 · COMP-007 · FLOW-007 · OP-007 · F-007
@MainActor
struct ListActiveCountersFeature {
    let store: SmallCountStore

    func listActiveCounters() async throws -> [Counter] {
        try Task.checkCancellation()
        return store.snapshot.counters
            .filter { !$0.archived }
            .sorted { lhs, rhs in
                let comparison = lhs.name.localizedCaseInsensitiveCompare(rhs.name)
                return comparison == .orderedSame
                    ? lhs.id.uuidString < rhs.id.uuidString
                    : comparison == .orderedAscending
            }
    }
}
