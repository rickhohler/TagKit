import XCTest
@testable import TagCore
@testable import TagIntelligence

@available(macOS 10.15, *)
final class TextTaggerTests: XCTestCase {
    
    func testTextTagger() async {
        let text = "Steve Jobs founded Apple in California."
        let tagger = TextTagger()
        
        // This test might be flaky depending on OS version ML model, checking for *some* output
        let tags = await tagger.process(text)
        
        XCTAssertFalse(tags.isEmpty)
        XCTAssertTrue(tags.contains { $0.displayName.contains("Apple") || $0.displayName.contains("California") })
        
        if let appleTag = tags.first(where: { $0.displayName.contains("Apple") }) {
            XCTAssertEqual(appleTag.source, .artificialIntelligence(model: "NLTagger"))
        }
    }
}
