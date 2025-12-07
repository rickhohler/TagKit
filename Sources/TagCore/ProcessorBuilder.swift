import Foundation

/// A fluent builder for constructing composite processors.
public class ProcessorBuilder<Input> {
    private var processors: [any TagProcessor<Input>] = []
    
    public init() {}
    
    /// Adds a processor to the pipeline.
    public func add<P: TagProcessor>(_ processor: P) -> ProcessorBuilder where P.Input == Input {
        processors.append(processor)
        return self
    }
    
    /// Builds the final composite processor.
    public func build() -> CompositeProcessor<Input> {
        return CompositeProcessor(processors: processors)
    }
}
