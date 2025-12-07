import XCTest
import TagKit
import TagCore

@available(macOS 10.15, *)
final class CustomProcessorTests: XCTestCase {
    
    struct MockProcess: TagProcessor {
        func process(_ input: String) async throws -> [Tag] {
            return [Tag(name: "Mock: \(input)")]
        }
    }
    
    func testCustomPipeline() async throws {
        let pipeline = TagKit.makePipeline()
            .add(MockProcess())
            .build()
        
        let tags = try await pipeline.process("Test")
        XCTAssertEqual(tags.first?.displayName, "Mock: Test")
    }
}
