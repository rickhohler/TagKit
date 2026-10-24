// TagExtraction - Label Text Parser
//
// Serial and model numbers from equipment label text.

import Foundation

/// A value read from a label, with how confident the parser is.
public struct ExtractedLabelValue: Equatable, Sendable {
    public let value: String
    public let confidence: Double

    public init(value: String, confidence: Double) {
        self.value = value
        self.confidence = confidence
    }
}

/// Identifiers found in a label's text. Either may be absent.
public struct LabelTextExtraction: Equatable, Sendable {
    public var serialNumber: ExtractedLabelValue?
    public var modelNumber: ExtractedLabelValue?

    public init(serialNumber: ExtractedLabelValue? = nil, modelNumber: ExtractedLabelValue? = nil) {
        self.serialNumber = serialNumber
        self.modelNumber = modelNumber
    }

    public static let empty = LabelTextExtraction()
}

/// Extracts serial and model numbers from text lines read off an equipment label (for example
/// by OCR): values after "SERIAL NO.", "S/N", "MODEL" and similar labels, on the same or the next
/// line, and otherwise tokens matching known model-number formats supplied by the caller. Lines
/// are expected in reading order.
public struct LabelTextParser: Sendable {
    /// Model-number formats tried when no "MODEL" label is found (for example a vendor's catalog
    /// number scheme). Matched against whole tokens.
    public let modelPatterns: [NSRegularExpression]

    public init(modelPatterns: [NSRegularExpression] = []) {
        self.modelPatterns = modelPatterns
    }


    // Confidence tiers: label on the same line > label on the previous line > format match only.
    public static let serialSameLineConfidence = 0.95
    public static let serialNextLineConfidence = 0.75
    public static let modelSameLineConfidence = 0.9
    public static let modelNextLineConfidence = 0.7
    public static let modelPatternConfidence = 0.6

    public func parse(_ lines: [String]) -> LabelTextExtraction {
        let normalized = lines
            .map { $0.uppercased().trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let serial = Self.labeledValue(in: normalized, label: Self.serialLabel,
                                  sameLine: Self.serialSameLineConfidence, nextLine: Self.serialNextLineConfidence,
                                  excluding: nil)
        let model = Self.labeledValue(in: normalized, label: Self.modelLabel,
                                 sameLine: Self.modelSameLineConfidence, nextLine: Self.modelNextLineConfidence,
                                 excluding: serial?.value)
            ?? patternModel(in: normalized, excluding: serial?.value)

        return LabelTextExtraction(serialNumber: serial, modelNumber: model)
    }

    // MARK: - Labels

    // Longest alternatives first so "SERIAL NUMBER" is consumed whole rather than as "SERIAL".
    private static let serialLabel = regex(
        #"\b(?:SERIAL\s*(?:NUMBER|NUM\b\.?|NO\b\.?|#)?|SER\b\.?\s*(?:NO\b\.?|#)|S\s*/\s*N\b|SN\b)"#
    )
    // `MOD\b` cannot match inside "MODEL" or "MODE".
    private static let modelLabel = regex(
        #"\b(?:MODEL\s*(?:NUMBER|NO\b\.?|#)?|MOD\b\.?)"#
    )

    /// Finds the first label occurrence that has a valid value on its own line or, failing that, the next line.
    private static func labeledValue(
        in lines: [String],
        label: NSRegularExpression,
        sameLine: Double,
        nextLine: Double,
        excluding excluded: String?
    ) -> ExtractedLabelValue? {
        for (index, line) in lines.enumerated() {
            let range = NSRange(line.startIndex..., in: line)
            for match in label.matches(in: line, range: range) {
                guard let labelRange = Range(match.range, in: line) else { continue }
                let rest = String(line[labelRange.upperBound...])
                if let value = firstToken(of: rest), isValidIdentifier(value), value != excluded {
                    return ExtractedLabelValue(value: value, confidence: sameLine)
                }
                // Label with nothing usable after it: the value is often printed on the line below.
                if index + 1 < lines.count,
                   let value = firstToken(of: lines[index + 1]), isValidIdentifier(value), value != excluded {
                    return ExtractedLabelValue(value: value, confidence: nextLine)
                }
            }
        }
        return nil
    }

    // MARK: - Known model-number formats


    private func patternModel(in lines: [String], excluding excluded: String?) -> ExtractedLabelValue? {
        for line in lines {
            for token in Self.tokens(of: line) where token != excluded && Self.isValidIdentifier(token) {
                let range = NSRange(token.startIndex..., in: token)
                if modelPatterns.contains(where: { $0.firstMatch(in: token, range: range) != nil }) {
                    return ExtractedLabelValue(value: token, confidence: Self.modelPatternConfidence)
                }
            }
        }
        return nil
    }

    // MARK: - Validation

    private static let ignoredValuePatterns: [NSRegularExpression] = [
        regex(#"^\d+(?:\.\d+)?(?:V|VAC|VDC|HZ|KHZ|MHZ|A|MA|W|VA)$"#),  // 120V, 60HZ, 0.5A
        regex(#"^\d+/\d+(?:HZ)?$"#),                                     // 50/60, 50/60HZ
        regex(#"^(?:19[5-9]\d|20[0-2]\d)$"#),                            // bare years
    ]

    /// 3–24 characters, contains a digit, and isn't an electrical rating or a year.
    /// 3-24 characters with at least one digit, and not a voltage, frequency, current or bare year.
    public static func isValidIdentifier(_ value: String) -> Bool {
        guard (3...24).contains(value.count),
              value.contains(where: \.isNumber) else { return false }
        let range = NSRange(value.startIndex..., in: value)
        return !ignoredValuePatterns.contains { $0.firstMatch(in: value, range: range) != nil }
    }

    // MARK: - Tokenizing

    private static let trimmedPunctuation = CharacterSet(charactersIn: ":;,.#-/()[]\"'")
        .union(.whitespaces)

    private static func tokens(of text: String) -> [String] {
        text.split(whereSeparator: { $0.isWhitespace || $0 == "," })
            .map { $0.trimmingCharacters(in: trimmedPunctuation) }
            .filter { !$0.isEmpty }
    }

    private static func firstToken(of text: String) -> String? {
        tokens(of: text).first
    }

    private static func regex(_ pattern: String) -> NSRegularExpression {
        // Patterns are compile-time constants; a failure here is a programming error.
        try! NSRegularExpression(pattern: pattern)
    }
}
