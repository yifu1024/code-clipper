import Foundation
import SQLite3

enum MessagesPermissionState: Equatable {
    case checking
    case granted
    case denied(String)
}

actor MessagesPermissionChecker {
    private let databaseURL: URL

    init(databaseURL: URL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Messages/chat.db")) {
        self.databaseURL = databaseURL
    }

    func check() -> MessagesPermissionState {
        guard FileManager.default.fileExists(atPath: databaseURL.path) else {
            return .denied("没有找到信息数据库：\(databaseURL.path)")
        }

        var database: OpaquePointer?
        let status = sqlite3_open_v2(databaseURL.path, &database, SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX, nil)
        defer {
            if let database {
                sqlite3_close(database)
            }
        }

        guard status == SQLITE_OK else {
            return .denied("无法打开信息数据库。请给 ~/Applications/CodeClipper.app 完全磁盘访问权限。")
        }

        return .granted
    }
}
