import Foundation

struct LocalTimeAdapter: LocalTimeProviding {
    private let now: @Sendable () -> Date
    private let calendar: Calendar
    private let timeZone: TimeZone

    init(
        now: @escaping @Sendable () -> Date = { Date() },
        calendar: Calendar = Calendar.current,
        timeZone: TimeZone = TimeZone.current
    ) {
        var capturedCalendar = calendar
        capturedCalendar.timeZone = timeZone
        self.now = now
        self.calendar = capturedCalendar
        self.timeZone = timeZone
    }

    func currentInstant() async throws -> Date {
        try Task.checkCancellation()
        return now()
    }

    func currentTimeZoneIdentifier() async throws -> String {
        try Task.checkCancellation()
        return timeZone.identifier
    }

    func dayInterval(containing date: Date) async throws -> DateInterval {
        try Task.checkCancellation()
        guard let interval = calendar.dateInterval(of: .day, for: date) else {
            throw CocoaError(.validationMissingMandatoryProperty)
        }
        return interval
    }
}
