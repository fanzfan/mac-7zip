import SwiftUI

/// Tracks the current processing state of the application.
enum ProcessingState: Equatable {
    case idle
    case processing(description: String)
    case success(message: String)
    case failure(message: String)
}

/// View model that coordinates drag-and-drop actions with the SevenZipWrapper.
@MainActor
final class ArchiveViewModel: ObservableObject {

    @Published var state: ProcessingState = .idle
    @Published var progressText: String = ""

    /// Handle one or more dropped file URLs.
    func handleDroppedURLs(_ urls: [URL]) {
        guard let url = urls.first else { return }
        let path = url.path
        let fileType = FileType.detect(url: url)

        switch fileType {
        case .archive:
            decompress(archivePath: path)
        case .regular:
            compress(inputPath: path)
        }
    }

    /// Compress a file or folder into a .7z archive.
    private func compress(inputPath: String) {
        state = .processing(description: "Compressing…")
        progressText = ""

        Task {
            do {
                let result = try await SevenZipWrapper.compress(inputPath: inputPath) { [weak self] line in
                    Task { @MainActor in
                        self?.progressText = line
                    }
                }
                if result.success {
                    state = .success(message: "Compression complete.")
                } else {
                    state = .failure(message: result.errorOutput.isEmpty
                        ? "Compression failed (exit code \(result.exitCode))."
                        : result.errorOutput)
                }
            } catch {
                state = .failure(message: error.localizedDescription)
            }
        }
    }

    /// Decompress an archive to the same directory.
    private func decompress(archivePath: String) {
        state = .processing(description: "Extracting…")
        progressText = ""

        Task {
            do {
                let result = try await SevenZipWrapper.decompress(archivePath: archivePath) { [weak self] line in
                    Task { @MainActor in
                        self?.progressText = line
                    }
                }
                if result.success {
                    state = .success(message: "Extraction complete.")
                } else {
                    state = .failure(message: result.errorOutput.isEmpty
                        ? "Extraction failed (exit code \(result.exitCode))."
                        : result.errorOutput)
                }
            } catch {
                state = .failure(message: error.localizedDescription)
            }
        }
    }

    /// Reset to idle state.
    func reset() {
        state = .idle
        progressText = ""
    }
}
