# TagKit

**TagKit** is a Swift framework designed for handling tags and tag extraction from various data sources.

## Features

- **TagCore**: Core types and definitions for tagging.
- **TagExtraction**: mechanisms for identifying and extracting tags from images, text files, PDFs, and more.

## Installation

Add `TagKit` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/rickhohler/TagKit.git", from: "1.0.0")
]
```

## Usage

### Basic Usage
Use the `TagKit` facade to create processors:

```swift
import TagKit

// 1. Process an Image (Objects + Text)
let imageProcessor = TagKit.makeImageProcessor()
let tags = try await imageProcessor.process(myImage)

// 2. Process a PDF
let pdfProcessor = TagKit.makePDFProcessor()
let tags = try await pdfProcessor.process(pdfData)

// 3. Process Text
let textTagger = TagKit.makeTextProcessor()
let tags = await textTagger.process("Apple released new products.")
```

### Advanced Usage (Builder Pattern)
Construct custom pipelines:

```swift
let customProcessor = ProcessorBuilder<PlatformImage>()
    .add(ImageObjectProcessor()) // Vision (Classes)
    .add(ImageTextProcessor())   // Vision (OCR)
    .build()
```

## Structure

- `TagCore`: Defines the fundamental `Tag` types.
- `TagExtraction`: Logic for parsing and extracting tags.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
