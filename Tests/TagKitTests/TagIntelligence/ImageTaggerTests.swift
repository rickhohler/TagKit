import XCTest
@testable import TagCore
@testable import TagIntelligence

#if canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#endif

@available(macOS 10.15, *)
final class ImageTaggerTests: XCTestCase {
    
    func testImageTagger() async throws {
        // Load resource
        guard let url = Bundle.module.url(forResource: "sample", withExtension: "jpg") ?? 
                        Bundle.module.url(forResource: "sample", withExtension: "jpg", subdirectory: "TagIntelligence/Resources") else {
            XCTFail("Missing sample.jpg")
            return
        }
        
        let data = try Data(contentsOf: url)
        guard let image = PlatformImage(data: data) else {
            XCTFail("Could not create image from data")
            return
        }
        
        let processor = ImageTagger.makeProcessor()
        let tags = try await processor.process(image)
        
        XCTAssertFalse(tags.isEmpty)
        // Cat image should probably contain "cat" or "mammal" or "animal"
        XCTAssertTrue(tags.contains { $0.slug.contains("cat") || $0.slug.contains("animal") })
    }
}
