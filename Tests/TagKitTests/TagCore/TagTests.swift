import XCTest
@testable import TagCore

final class TagTests: XCTestCase {
    
    func testTagInitialization() {
        let tag = Tag(name: "Artificial Intelligence")
        
        XCTAssertEqual(tag.displayName, "Artificial Intelligence")
        XCTAssertEqual(tag.slug, "artificial-intelligence")
        XCTAssertEqual(tag.score, 1.0)
        XCTAssertEqual(tag.source, .user)
        XCTAssertEqual(tag.status, .confirmed)
        XCTAssertEqual(tag.reliability, 1.0)
    }
    
    func testAITagDefaults() {
        let tag = Tag(name: "Swift", score: 0.85, source: .artificialIntelligence(model: "TestModel"))
        
        XCTAssertEqual(tag.status, .suggested)
        XCTAssertEqual(tag.reliability, 0.85)
    }
    
    func testSlugGeneration() {
        let tag1 = Tag(name: "  Hello World!  ")
        XCTAssertEqual(tag1.slug, "hello-world")
        
        let tag2 = Tag(name: "C++ Programming")
        XCTAssertEqual(tag2.slug, "c-programming") // basic filter for now
        
        let tag3 = Tag(name: "Swift 6.0")
        XCTAssertEqual(tag3.slug, "swift-6.0")
    }
}
