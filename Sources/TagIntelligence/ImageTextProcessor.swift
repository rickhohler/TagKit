import Foundation
import Vision
import TagCore

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Extracts text from images using Vision (OCR) and converts it into tags.
@available(macOS 10.15, *)
public class ImageTextProcessor: TagProcessor {
    
    private let textTagger = TextTagger()
    
    public init() {}
    
    public func process(_ image: PlatformImage) async throws -> [Tag] {
        return try await withCheckedThrowingContinuation { continuation in
            #if canImport(AppKit)
            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                continuation.resume(throwing: ProcessingError.invalidImage)
                return
            }
            #elseif canImport(UIKit)
            guard let cgImage = image.cgImage else {
                continuation.resume(throwing: ProcessingError.invalidImage)
                return
            }
            #endif
            
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
                let fullText = recognizedStrings.joined(separator: " ")
                
                Task {
                    // Create local instance to avoid capture issues
                    let localTagger = TextTagger()
                    let tags = await localTagger.process(fullText)
                    continuation.resume(returning: tags)
                }
            }
            // Use accurate recognition level
            request.recognitionLevel = .accurate
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public enum ProcessingError: Error {
        case invalidImage
    }
}
