import Foundation

enum AttributedBodyExtractor {
    static func extractReadableText(from data: Data) -> String? {
        let utf8 = String(decoding: data, as: UTF8.self)
        let candidates = utf8
            .components(separatedBy: CharacterSet.controlCharacters)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { candidate in
                candidate.count >= 4 && candidate.rangeOfCharacter(from: .decimalDigits) != nil
            }

        return candidates.max(by: { $0.count < $1.count })
    }
}
