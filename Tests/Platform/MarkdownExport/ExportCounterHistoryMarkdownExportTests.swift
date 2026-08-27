import Foundation
import Testing
@testable import SmallCount

@Suite("TASK-011 EXPORT-009 canonical Markdown")
struct ExportCounterHistoryMarkdownExportTests {
    @Test("emits exact deterministic UTF-8 LF byte grammar")
    func exactBytes() throws {
        let counterID = try #require(UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"))
        let eventID = try #require(UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"))
        let snapshot = SmallCountSnapshot(
            schemaVersion: 1,
            counters: [.init(id: counterID, name: "A/B\nC", color: nil, archived: false)],
            events: [.init(id: eventID, occurredAt: Date(timeIntervalSince1970: 0), counterID: counterID)]
        )
        let data = try ExportCounterHistoryMarkdownExport().data(for: snapshot)
        let expected = """
        # Swiftpiler Markdown Export v1

        ## Entity: Counter

        ### Record: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
        - `id`: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
        - `name`: "A/B\\nC"
        - `color`: null
        - `archived`: false

        ## Entity: Event

        ### Record: bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
        - `id`: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
        - `occurredAt`: "1970-01-01T00:00:00.000Z"
        - `counterID`: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"

        """
        #expect(data == Data(expected.utf8))
    }

    @Test("empty entities use the canonical no-records token")
    func emptyRecords() throws {
        let data = try ExportCounterHistoryMarkdownExport().data(for: .empty)
        let markdown = String(decoding: data, as: UTF8.self)

        #expect(markdown.contains("## Entity: Counter\n\n_No records._\n"))
        #expect(markdown.contains("## Entity: Event\n\n_No records._\n"))
        #expect(markdown.hasSuffix("\n"))
    }
}
