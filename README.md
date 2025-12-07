# TagKit
[![Tests](https://github.com/rickhohler/TagKit/actions/workflows/test.yml/badge.svg)](https://github.com/rickhohler/TagKit/actions/workflows/test.yml)
[![Documentation](https://github.com/rickhohler/TagKit/actions/workflows/docs.yml/badge.svg)](https://github.com/rickhohler/TagKit/actions/workflows/docs.yml)
[![codecov](https://codecov.io/gh/rickhohler/TagKit/branch/main/graph/badge.svg)](https://codecov.io/gh/rickhohler/TagKit)

[![Release](https://img.shields.io/github/v/release/rickhohler/TagKit)](https://github.com/rickhohler/TagKit/releases)

**TagKit** is a Swift framework designed for handling tags and tag extraction from various data sources.

## Features

- **TagCore**: Core types and definitions for tagging.
- **TagExtraction**: mechanisms for identifying and extracting tags from images, text files, PDFs, and more.

## Installation

Add `TagKit` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/rickhohler/TagKit.git", from: "<latest_version>")
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

## Contributing

At this time, `TagKit` is closed to external contributions.

**All issues, bugs, and feature requests are tracked via [GitHub Issues](https://github.com/rickhohler/TagKit/issues).**

Please check existing issues before filing a new one.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
