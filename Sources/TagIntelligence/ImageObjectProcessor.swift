import Foundation
import Vision
import TagCore

#if canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#elseif canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#endif

/// Identifies objects in images and suggests tags using the Vision framework.
@available(macOS 10.15, *)
public class ImageObjectProcessor: TagProcessor {
    
    public init() {}
    
    /// Analyzes an image and returns a list of tags with confidence scores.
    public func process(_ image: PlatformImage) async throws -> [Tag] {
        return try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                continuation.resume(throwing: TaggingError.invalidImage)
                return
            }
            
            let request = VNClassifyImageRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                // Filter for reasonable confidence and map to Tags
                let tags = results
                    .filter { $0.confidence > 0.3 }
                    .prefix(10) // Top 10
                    .map { observation in
                        Tag(name: observation.identifier,
                            score: Double(observation.confidence),
                            source: .artificialIntelligence(model: "VNClassifyImageRequest"))
                    }
                
                continuation.resume(returning: Array(tags))
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public enum TaggingError: Error {
        case invalidImage
    }
}
