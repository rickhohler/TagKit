import Foundation
import PDFKit
import TagCore
import TagIntelligence

#if canImport(PDFKit)

/// Extracts tags from PDF documents by analyzing their text content.
@available(macOS 10.15, *)
public struct PDFTagProcessor: TagProcessor {
    public typealias Input = Data
    
    private let textTagger = TextTagger()
    
    public init() {}
    
    public func process(_ data: Data) async throws -> [Tag] {
        guard let pdfDocument = PDFDocument(data: data) else {
            throw ERROR.invalidPDF
        }
        
        // Extract text from all pages
        var fullText = ""
        let pageCount = pdfDocument.pageCount
        
        for i in 0..<pageCount {
            if let page = pdfDocument.page(at: i), let pageText = page.string {
                fullText += pageText + "\n"
            }
        }
        
        // Use TagIntelligence to find tags in the text
        return await textTagger.process(fullText)
    }
    
    public enum ERROR: Error {
        case invalidPDF
    }
}

#endif
