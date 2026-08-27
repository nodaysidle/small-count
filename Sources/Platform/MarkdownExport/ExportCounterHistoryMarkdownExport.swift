import Foundation

// EXPORT-009 · F-009
struct ExportCounterHistoryMarkdownExport: Sendable {
    func data(for snapshot: SmallCountSnapshot) throws -> Data {
        let counters = snapshot.counters.sorted { $0.id.uuidString < $1.id.uuidString }
        let events = snapshot.events.sorted { $0.id.uuidString < $1.id.uuidString }

        let counterRecords = try counters.map { counter in
            record(
                id: counter.id,
                fields: [
                    ("id", try scalar(counter.id.uuidString.lowercased())),
                    ("name", try scalar(counter.name)),
                    ("color", try counter.color.map(scalar) ?? "null"),
                    ("archived", counter.archived ? "true" : "false")
                ]
            )
        }
        let eventRecords = try events.map { event in
            record(
                id: event.id,
                fields: [
                    ("id", try scalar(event.id.uuidString.lowercased())),
                    ("occurredAt", try scalar(timestamp(event.occurredAt))),
                    ("counterID", try scalar(event.counterID.uuidString.lowercased()))
                ]
            )
        }

        let sections = [
            "# Swiftpiler Markdown Export v1",
            entity(name: "Counter", records: counterRecords),
            entity(name: "Event", records: eventRecords)
        ]
        return Data((sections.joined(separator: "\n\n") + "\n").utf8)
    }

    private func entity(name: String, records: [String]) -> String {
        let body = records.isEmpty ? "_No records._" : records.joined(separator: "\n\n")
        return "## Entity: \(name)\n\n\(body)"
    }

    private func record(id: UUID, fields: [(String, String)]) -> String {
        let lines = fields.map { "- `\($0.0)`: \($0.1)" }.joined(separator: "\n")
        return "### Record: \(id.uuidString.lowercased())\n\(lines)"
    }

    private func scalar(_ value: String) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: [value], options: [.withoutEscapingSlashes])
        let encoded = String(decoding: data, as: UTF8.self)
        return String(encoded.dropFirst().dropLast())
    }

    private func timestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
