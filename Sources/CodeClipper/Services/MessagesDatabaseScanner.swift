import Foundation
import SQLite3

enum MessagesDatabaseScannerError: LocalizedError {
    case databaseNotFound(URL)
    case openFailed(String)
    case queryFailed(String)

    var errorDescription: String? {
        switch self {
        case .databaseNotFound(let url):
            return "Messages database was not found at \(url.path)."
        case .openFailed:
            return "Cannot open Messages database. Grant Full Disk Access to CodeClipper, then try again."
        case .queryFailed(let message):
            return "Messages query failed: \(message)"
        }
    }
}

actor MessagesDatabaseScanner {
    private let databaseURL: URL

    init(databaseURL: URL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Messages/chat.db")) {
        self.databaseURL = databaseURL
    }

    func recentIncomingMessages(lookbackMinutes: Double) throws -> [MessageRecord] {
        guard FileManager.default.fileExists(atPath: databaseURL.path) else {
            throw MessagesDatabaseScannerError.databaseNotFound(databaseURL)
        }

        var database: OpaquePointer?
        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(databaseURL.path, &database, flags, nil) == SQLITE_OK else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "unknown"
            throw MessagesDatabaseScannerError.openFailed(message)
        }
        defer { sqlite3_close(database) }

        let since = Date().addingTimeInterval(-lookbackMinutes * 60)
        let threshold = MessagesDatabaseScanner.appleMessageDate(from: since)
        let sql = """
        SELECT ROWID, date, text, attributedBody
        FROM message
        WHERE is_from_me = 0 AND date >= ?
        ORDER BY date DESC
        LIMIT 80
        """

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw MessagesDatabaseScannerError.queryFailed(String(cString: sqlite3_errmsg(database)))
        }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_int64(statement, 1, threshold)

        var records: [MessageRecord] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            let dateValue = sqlite3_column_int64(statement, 1)
            let text = sqlite3_column_text(statement, 2).map { String(cString: $0) }
            let body = text ?? attributedBodyText(from: statement, column: 3)

            guard let body, !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                continue
            }

            records.append(
                MessageRecord(
                    id: id,
                    receivedAt: Self.date(fromAppleMessageDate: dateValue),
                    body: body
                )
            )
        }

        return records
    }

    private func attributedBodyText(from statement: OpaquePointer?, column: Int32) -> String? {
        guard let bytes = sqlite3_column_blob(statement, column) else { return nil }
        let count = Int(sqlite3_column_bytes(statement, column))
        guard count > 0 else { return nil }

        let data = Data(bytes: bytes, count: count)
        return AttributedBodyExtractor.extractReadableText(from: data)
    }

    private static func appleMessageDate(from date: Date) -> Int64 {
        Int64(date.timeIntervalSinceReferenceDate * 1_000_000_000)
    }

    private static func date(fromAppleMessageDate value: Int64) -> Date {
        if value > 10_000_000_000_000 {
            return Date(timeIntervalSinceReferenceDate: TimeInterval(value) / 1_000_000_000)
        }

        return Date(timeIntervalSinceReferenceDate: TimeInterval(value))
    }
}
