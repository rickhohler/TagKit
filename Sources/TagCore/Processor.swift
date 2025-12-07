import Foundation

/// A generic protocol defining the capability to process input data into structured output.
public protocol Processor<Input, Output> {
    /// The input source type (e.g., URL, String, Data).
    associatedtype Input
    
    /// The type of information produced.
    associatedtype Output
    
    /// Processes the given input.
    /// - Parameter input: The source data to analyze.
    /// - Returns: The processed output.
    func process(_ input: Input) async throws -> Output
}
