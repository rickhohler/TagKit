import Foundation
import Testing
@testable import TagExtraction

@Suite("Label Text Parser")
struct LabelTextParserTests {
    let parser = LabelTextParser()

    @Test("Same-line serial label")
    func sameLineSerial() {
        let result = parser.parse(["S/N: X12-3456"])
        #expect(result.serialNumber == ExtractedLabelValue(value: "X12-3456", confidence: LabelTextParser.serialSameLineConfidence))
    }

    @Test("Serial value on the next line")
    func nextLineSerial() {
        #expect(parser.parse(["SERIAL NO.", "640021"]).serialNumber?.value == "640021")
    }

    @Test("Serial label variants", arguments: [
        "SN 88123", "SN: 88123", "Ser. No. 88123", "SER # 88123",
        "Serial Number: 88123", "serial #88123", "S / N 88123",
    ])
    func serialLabelVariants(line: String) {
        #expect(parser.parse([line]).serialNumber?.value == "88123")
    }

    @Test("Labeled model number")
    func labeledModel() {
        #expect(parser.parse(["Model No.", "XK2064"]).modelNumber?.value == "XK2064")
        #expect(parser.parse(["MODE 40 COLUMN"]).modelNumber == nil)
    }

    @Test("Model patterns come from the caller")
    func callerModelPatterns() throws {
        #expect(parser.parse(["ACME ZZ1234"]).modelNumber == nil)
        let custom = LabelTextParser(modelPatterns: [try NSRegularExpression(pattern: #"^ZZ\d{4}$"#)])
        #expect(custom.parse(["ACME ZZ1234"]).modelNumber
            == ExtractedLabelValue(value: "ZZ1234", confidence: LabelTextParser.modelPatternConfidence))
    }

    @Test("Electrical ratings and years are not identifiers", arguments: ["120V", "60HZ", "0.5A", "50/60HZ", "1984"])
    func ignoredValues(value: String) {
        #expect(!LabelTextParser.isValidIdentifier(value))
    }
}
