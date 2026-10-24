import Foundation
import Testing
import UniformTypeIdentifiers
@testable import TagKit

@Suite("File Tagger")
struct FileTaggerTests {
    @Test("Content kind from the file name", arguments: [
        ("photo.jpg", FileTagger.ContentKind.image), ("scan.HEIC", .image), ("manual.pdf", .pdf),
        ("readme.txt", .text), ("notes.md", .text), ("main.swift", .text), ("data.json", .text),
    ])
    func kindFromFilename(filename: String, expected: FileTagger.ContentKind) {
        #expect(FileTagger.contentKind(filename: filename) == expected)
    }

    @Test("Unknown types are not tagged")
    func unknownType() async throws {
        #expect(FileTagger.contentKind(filename: "game.dsk") == nil)
        #expect(FileTagger.contentKind(filename: "noextension") == nil)
        let tags = try await FileTagger().analyze(data: Data([0, 1, 2]), filename: "game.dsk")
        #expect(tags.isEmpty)
    }

    @Test("An explicit content type wins over the extension")
    func explicitContentType() {
        #expect(FileTagger.contentKind(filename: "file.bin", contentType: UTType.plainText.identifier) == .text)
    }
}
