import Foundation

/// A structured representation of a tag, supporting both manual and automated tagging scenarios.
public struct Tag: Identifiable, Hashable, Sendable {
    public let id: UUID
    
    /// A short, URL-friendly identifier for the tag (e.g., "ai-tools").
    /// This is typically used for internal references or URLs, distinct from the human-readable `displayName`.
    public let slug: String
    
    public let displayName: String
    public let score: Double
    public let source: TagSource
    public var status: Status

    /// A computed reliability score based on the raw score and source.
    public var reliability: Double {
        switch source {
        case .user:
            return 1.0 // User tags are always reliable
        case .artificialIntelligence:
            return score // AI tags depend on the model's confidence
        case .imported:
            return 1.0
        case .unknown:
            return 0.5
        }
    }

    public enum TagSource: Hashable, Sendable {
        case user
        case artificialIntelligence(model: String)
        case imported
        case unknown
    }
    
    public enum Status: Hashable, Sendable {
        case suggested
        case confirmed
        case rejected
    }

    /// Initializes a new Tag.
    /// - Parameters:
    ///   - name: The display name of the tag. The slug will be automatically generated.
    public init(id: UUID = UUID(), name: String, score: Double = 1.0, source: TagSource = .user, status: Status? = nil) {
        self.id = id
        self.displayName = name
        // Simple slug generation: lowercase, replace non-alphanumeric with hyphens
        self.slug = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        .lowercased()
                        .replacingOccurrences(of: " ", with: "-")
                        .filter { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "." }
        self.score = score
        self.source = source
        
        if let status = status {
            self.status = status
        } else {
            // Default status logic
            switch source {
            case .user, .imported:
                self.status = .confirmed
            case .artificialIntelligence, .unknown:
                self.status = .suggested
            }
        }
    }
}
