import Foundation
import NaturalLanguage
import TagCore

/// Groups tags based on semantic similarity using Natural Language embeddings.
@available(macOS 10.15, *)
public struct TagGrouper {
    
    public init() {}
    
    /// Calculates the semantic distance between two tags.
    /// - Returns: A value between 0 (identical) and 2 (opposites), or nil if not found.
    public func distance(between tag1: String, and tag2: String) -> Double? {
        guard let embedding = NLEmbedding.wordEmbedding(for: .english) else { return nil }
        return embedding.distance(between: tag1, and: tag2)
    }
    
    /// Finds neighbors for a given tag (e.g., synonyms or related concepts).
    public func relatedTags(for tag: String, maxCount: Int = 5) -> [String] {
        guard let embedding = NLEmbedding.wordEmbedding(for: .english) else { return [] }
        return embedding.neighbors(for: tag, maximumCount: maxCount).map { $0.0 }
    }
    
    /// Groups a list of tags into semantic clusters.
    /// Simple implementation: aligns tags to their closest "centroid" if provided, or simple pair-wise grouping.
    /// This is a placeholder for more advanced clustering logic.
    public func findSynonyms(in tags: [Tag]) -> [[Tag]] {
        // Basic O(n^2) approach for demo purposes: find very close matches
        var groups: [[Tag]] = []
        var processed: Set<UUID> = []
        
        guard let embedding = NLEmbedding.wordEmbedding(for: .english) else { return [] }
        
        for tag1 in tags {
            if processed.contains(tag1.id) { continue }
            
            var group = [tag1]
            processed.insert(tag1.id)
            
            for tag2 in tags {
                if processed.contains(tag2.id) { continue }
                
                let dist = embedding.distance(between: tag1.displayName, and: tag2.displayName)
                if dist < 0.3 {
                    group.append(tag2)
                    processed.insert(tag2.id)
                }
            }
            if group.count > 1 {
                groups.append(group)
            }
        }
        
        return groups
    }
}
