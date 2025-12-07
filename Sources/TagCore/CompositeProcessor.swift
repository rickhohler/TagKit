import Foundation

/// A processor that delegates to multiple child processors and aggregates their results.
public struct CompositeProcessor<Input>: TagProcessor {
    private let processors: [AnyTagProcessor<Input>]
    
    public init(processors: [any TagProcessor<Input>]) {
        self.processors = processors.map { AnyTagProcessor($0) }
    }
    
    public func process(_ input: Input) async throws -> [Tag] {
        var allTags: [Tag] = []
        
        // Run all processors potentially in parallel (TaskGroup) or serial
        // For simplicity/safety, serial first.
        for processor in processors {
            let tags = try await processor.process(input)
            allTags.append(contentsOf: tags)
        }
        
        // Remove duplicates (Tags are Hashable)
        return Array(Set(allTags))
    }
}

/// Type eraser for TagProcessor
public struct AnyTagProcessor<Input>: TagProcessor {
    private let _process: (Input) async throws -> [Tag]
    
    public init<P: TagProcessor>(_ processor: P) where P.Input == Input {
        self._process = processor.process
    }
    
    public func process(_ input: Input) async throws -> [Tag] {
        return try await _process(input)
    }
}
