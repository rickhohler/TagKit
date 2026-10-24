# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0-beta] - 2026-10-24
### Added
- **TagKit**: `FileTagger` tags image, PDF and text content, choosing the processor from a UTType
  (or the file name extension) and decoding in memory.
- **TagExtraction**: `LabelTextParser` extracts serial and model numbers from equipment label
  text, with caller-supplied model-number patterns; `LabelTextExtraction`, `ExtractedLabelValue`.

## [0.1.0-beta] - 2025-12-06
### Added
- **TagCore**:
    - `Tag` model with `slug`, `displayName`, `score`, `reliability`, and `status`.
    - `Processor` generic protocol.
    - `TagProcessor` protocol.
    - `CompositeProcessor` (Composite Pattern).
    - `ProcessorBuilder` (Builder Pattern).
- **TagIntelligence**:
    - `TextTagger` using `NLTagger` for Named Entity Recognition.
    - `ImageTagger` (Facade) supporting object classification and text recognition.
    - `ImageObjectProcessor` (Vision `VNClassifyImageRequest`).
    - `ImageTextProcessor` (Vision `VNRecognizeTextRequest`).
    - `TagGrouper` using `NLEmbedding` for semantic similarity.
- **TagExtraction**:
    - `PDFTagProcessor` using `PDFKit` to extract text and generate tags.
- **TagKit**:
    - `TagKit` main entry point (Facade) with factory methods.
- **Unit Tests**:
    - Comprehensive test suite for all modules.
    - Sample resources for PDF and Image testing.
