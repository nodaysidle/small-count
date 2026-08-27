import Foundation
@testable import SmallCount

@MainActor
final class TestPersistence: StructuredPersistenceProviding {
    var snapshot: SmallCountSnapshot
    var saveError: Error?

    init(snapshot: SmallCountSnapshot = .empty) {
        self.snapshot = snapshot
    }

    func loadSnapshot() async throws -> SmallCountSnapshot { snapshot }

    func saveSnapshot(snapshot: SmallCountSnapshot) async throws {
        if let saveError { throw saveError }
        self.snapshot = snapshot
    }

    func migrateStore(fromVersion: Int, toVersion: Int) async throws -> SmallCountSnapshot {
        snapshot
    }
}

struct FixedLocalTime: LocalTimeProviding {
    let instant: Date
    let zone: TimeZone
    let calendar: Calendar

    init(instant: Date, zone: TimeZone) {
        self.instant = instant
        self.zone = zone
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        self.calendar = calendar
    }

    func currentInstant() async throws -> Date { instant }
    func currentTimeZoneIdentifier() async throws -> String { zone.identifier }
    func dayInterval(containing date: Date) async throws -> DateInterval {
        guard let interval = calendar.dateInterval(of: .day, for: date) else { throw CancellationError() }
        return interval
    }
}

@MainActor
final class TestExportSelection: UserSelectedFileExportProviding {
    let destination: URL
    private(set) var suggestedNames: [String] = []

    init(destination: URL) {
        self.destination = destination
    }

    func selectExportDestination(suggestedName: String) async throws -> URL {
        suggestedNames.append(suggestedName)
        return destination
    }
}
