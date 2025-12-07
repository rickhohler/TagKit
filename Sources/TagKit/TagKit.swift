import Foundation
import TagCore
import TagIntelligence
import TagExtraction

#if canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#endif

/// The main entry point for the TagKit framework.
/// Provides factory methods for creating processors.
@available(macOS 10.15, *)
public struct TagKit {
    
    /// Creates a comprehensive image processor that handles both object recognition and text extraction.
    /// - Parameters:
    ///   - extractObjects: Defaults to true.
    ///   - extractText: Defaults to true.
    public static func makeImageProcessor(extractObjects: Bool = true, extractText: Bool = true) -> CompositeProcessor<PlatformImage> {
        return ImageTagger.makeProcessor(extractObjects: extractObjects, extractText: extractText)
    }
    
    /// Creates a PDF processor for extracting tags from PDF documents.
    public static func makePDFProcessor() -> PDFTagProcessor {
        return PDFTagProcessor()
    }
    
    /// Creates a text tagger for Named Entity Recognition.
    public static func makeTextProcessor() -> TextTagger {
        return TextTagger()
    }
    
    /// Creates a builder for constructing a custom processor pipeline.
    /// - Returns: A new `ProcessorBuilder` instance.
    public static func makePipeline<Input>() -> ProcessorBuilder<Input> {
        return ProcessorBuilder<Input>()
    }
}
