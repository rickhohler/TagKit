import Foundation
import TagCore

@available(macOS 10.15, *)
public struct ImageTagger {
    /// Returns a pre-built processor pipeline for images.
    /// - Parameters:
    ///   - extractObjects: Whether to identify objects (Vision classification).
    ///   - extractText: Whether to extract text (Vision OCR).
    public static func makeProcessor(extractObjects: Bool = true, extractText: Bool = true) -> CompositeProcessor<PlatformImage> {
        let builder = ProcessorBuilder<PlatformImage>()
        
        if extractObjects {
            _ = builder.add(ImageObjectProcessor())
        }
        
        if extractText {
            _ = builder.add(ImageTextProcessor())
        }
            
        return builder.build()
    }
}
