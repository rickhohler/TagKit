import Foundation
import UniformTypeIdentifiers
import TagCore
import TagIntelligence
import TagExtraction

/// Tags a file's content by its type: images (object recognition and text), PDF documents and
/// text. The type comes from a UTType (or its identifier), else from the file name extension.
@available(macOS 11.0, iOS 14.0, *)
public final class FileTagger: @unchecked Sendable {
    private let imageProcessor: CompositeProcessor<PlatformImage>
    private let textProcessor: TextTagger
    private let pdfProcessor: PDFTagProcessor

    public init(extractObjects: Bool = true, extractText: Bool = true) {
        imageProcessor = TagKit.makeImageProcessor(extractObjects: extractObjects, extractText: extractText)
        textProcessor = TagKit.makeTextProcessor()
        pdfProcessor = TagKit.makePDFProcessor()
    }

    /// The content kinds FileTagger can tag.
    public enum ContentKind: Sendable, Equatable {
        case image, pdf, text
    }

    /// The content kind for a type, or nil when the type is not tagged.
    public static func contentKind(for type: UTType) -> ContentKind? {
        if type.conforms(to: .image) { return .image }
        if type.conforms(to: .pdf) { return .pdf }
        if type.conforms(to: .text) || type.conforms(to: .json) || type.conforms(to: .sourceCode) { return .text }
        return nil
    }

    /// The content kind for a file name (by extension) or an explicit type identifier.
    public static func contentKind(filename: String, contentType: String? = nil) -> ContentKind? {
        if let contentType, let type = UTType(contentType) ?? UTType(filenameExtension: contentType) {
            return contentKind(for: type)
        }
        let ext = (filename as NSString).pathExtension
        guard !ext.isEmpty, let type = UTType(filenameExtension: ext) else { return nil }
        return contentKind(for: type)
    }

    /// Tags the file at `url`.
    /// - Parameter contentType: A UTType identifier or file extension; nil uses the URL's extension.
    public func analyze(url: URL, contentType: String? = nil) async throws -> [Tag] {
        guard Self.contentKind(filename: url.lastPathComponent, contentType: contentType) != nil else { return [] }
        return try await analyze(data: Data(contentsOf: url), filename: url.lastPathComponent, contentType: contentType)
    }

    /// Tags in-memory content named `filename` (used for its extension when `contentType` is nil).
    public func analyze(data: Data, filename: String, contentType: String? = nil) async throws -> [Tag] {
        switch Self.contentKind(filename: filename, contentType: contentType) {
        case .image:
            guard let image = PlatformImage(data: data) else { return [] }
            return try await imageProcessor.process(image)
        case .pdf:
            return try await pdfProcessor.process(data)
        case .text:
            guard let text = String(data: data, encoding: .utf8) else { return [] }
            return await textProcessor.process(text)
        case nil:
            return []
        }
    }
}
