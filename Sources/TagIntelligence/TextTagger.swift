import Foundation
import NaturalLanguage
import TagCore

/// Extracts tags (Named Entities) from text using Natural Language processing.
@available(macOS 10.15, *)
public struct TextTagger: TagProcessor {
    
    public init() {}
    
    /// Analyzes the text and returns tags for named entities (People, Places, Organizations).
    public func process(_ text: String) async -> [Tag] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var tags: [Tag] = []
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tagsOfInterest: [NLTag] = [.personalName, .placeName, .organizationName]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, tagsOfInterest.contains(tag) {
                let name = String(text[tokenRange])
                
                // Get score from hypotheses
                let (hypotheses, _) = tagger.tagHypotheses(at: tokenRange.lowerBound, unit: .word, scheme: .nameType, maximumCount: 1)
                let score = hypotheses[tag.rawValue] ?? 0.0
                
                let newTag = Tag(name: name, score: score, source: .artificialIntelligence(model: "NLTagger"))
                tags.append(newTag)
            }
            return true
        }
        
        return Array(Set(tags)) // Deduplicate
    }
}
