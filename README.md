# Mac7Zip

A native macOS desktop GUI application that wraps the 7-Zip command-line tool with a modern SwiftUI interface.

## Features

- **Drag & Drop** – Drop files directly onto the window to compress or decompress them.
- **Smart Detection** – Archives (`.7z`, `.zip`, `.tar`, `.gz`, `.rar`, etc.) are automatically extracted; all other files are compressed into `.7z` format.
- **Progress Feedback** – A live loading indicator and progress text while operations run.
- **App Sandbox** – Properly configured entitlements for reading and writing user-selected files.

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- The `7z` command-line binary (place it inside the app bundle at `Mac7Zip.app/Contents/Resources/7z`, or install it at `/usr/local/bin/7z`)

## Project Structure

```
Mac7Zip.xcodeproj/          Xcode project file
Mac7Zip/
  Mac7ZipApp.swift           App entry point
  ContentView.swift          Main window view
  DropZoneView.swift         Drag-and-drop zone UI
  ArchiveViewModel.swift     State management / ViewModel
  SevenZipWrapper.swift      Process-based 7z CLI wrapper
  FileType.swift             Archive vs. regular file detection
  Info.plist                 App metadata & document types
  Mac7Zip.entitlements       Sandbox permissions
  Assets.xcassets/           App icons & accent color
Mac7ZipTests/
  Mac7ZipTests.swift         Unit tests
```

## Build & Run

1. Open `Mac7Zip.xcodeproj` in Xcode.
2. Place the `7z` binary into `Mac7Zip/Resources/` (or ensure it is available at `/usr/local/bin/7z`).
3. Select the **Mac7Zip** scheme and press **⌘R** to build and run.

## Running Tests

Select the **Mac7ZipTests** target in Xcode and press **⌘U**, or run from the command line:

```bash
xcodebuild test -project Mac7Zip.xcodeproj -scheme Mac7Zip -destination 'platform=macOS'
```

## Architecture

| Layer | Responsibility |
|---|---|
| `Mac7ZipApp` | SwiftUI app lifecycle entry point |
| `ContentView` | Hosts the title bar and drop zone |
| `DropZoneView` | Renders the drop target and shows state (idle, processing, success, error) |
| `ArchiveViewModel` | Orchestrates compress/decompress logic, publishes UI state |
| `SevenZipWrapper` | Invokes the bundled `7z` binary via `Process`, streams stdout for progress |
| `FileType` | Classifies file paths/URLs as archive or regular |
