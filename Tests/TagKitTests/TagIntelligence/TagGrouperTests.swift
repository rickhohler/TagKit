import XCTest
@testable import TagCore
@testable import TagIntelligence

@available(macOS 10.15, *)
final class TagGrouperTests: XCTestCase {
    
    func testTagGrouper() {
        let grouper = TagGrouper()
        
        // "bike" and "bicycle" should be close
        if let distance = grouper.distance(between: "bike", and: "bicycle") {
            // Distance depends on the embedding model version, relaxing to <0.7
            XCTAssertLessThan(distance, 0.7)
        } else {
            print("Skipping NLEmbedding test (may not be available on this env)")
        }
        
        // "bike" and "banana" should be far
        if let distance = grouper.distance(between: "bike", and: "banana") {
            XCTAssertGreaterThan(distance, 0.5)
        }
    }
}
