import XCTest
@testable import TagCore
@testable import TagExtraction

@available(macOS 10.15, *)
final class PDFTagProcessorTests: XCTestCase {
    
    func testPDFTagProcessor() async throws {
        // Load resource
        guard let url = Bundle.module.url(forResource: "sample", withExtension: "pdf") ??
                        Bundle.module.url(forResource: "sample", withExtension: "pdf", subdirectory: "TagExtraction/Resources") else {
            XCTFail("Missing sample.pdf")
            return
        }
        
        let data = try Data(contentsOf: url)
        let processor = PDFTagProcessor()
        
        let tags = try await processor.process(data)
        
        // Dummy.pdf typically says "Dummy PDF file" so it might find "Dummy" or nothing if too short.
        // We mainly test that it doesn't crash and returns array.
        XCTAssertNotNil(tags)
    }
}
