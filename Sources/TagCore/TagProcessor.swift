import Foundation

/// A protocol defining the capability to process input into a list of Tags.
public protocol TagProcessor<Input>: Processor where Output == [Tag] {
    // Inherits func process(_ input: Input) async throws -> [Tag]
}
