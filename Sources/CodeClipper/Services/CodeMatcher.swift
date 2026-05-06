import Foundation

struct CodeMatcher {
    struct Match {
        let code: String
        let ruleName: String
    }

    func firstMatch(in text: String, rules: [VerificationRule]) -> Match? {
        for rule in rules where rule.isEnabled {
            guard let regex = try? NSRegularExpression(pattern: rule.pattern) else {
                continue
            }

            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            guard let result = regex.firstMatch(in: text, range: range) else {
                continue
            }

            let group = min(max(0, rule.captureGroup), result.numberOfRanges - 1)
            guard let codeRange = Range(result.range(at: group), in: text) else {
                continue
            }

            return Match(code: String(text[codeRange]), ruleName: rule.name)
        }

        return nil
    }
}
