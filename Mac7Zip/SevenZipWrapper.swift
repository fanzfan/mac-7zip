import Foundation

/// Result of a 7-Zip operation.
struct SevenZipResult {
    let success: Bool
    let output: String
    let errorOutput: String
    let exitCode: Int32
}

/// Wrapper around the 7z command-line binary bundled inside the app.
final class SevenZipWrapper {

    /// Errors specific to the wrapper.
    enum WrapperError: LocalizedError {
        case binaryNotFound
        case operationFailed(String)

        var errorDescription: String? {
            switch self {
            case .binaryNotFound:
                return "The 7z binary was not found in the application bundle."
            case .operationFailed(let message):
                return message
            }
        }
    }

    /// Resolves the path to the bundled 7z binary.
    /// Falls back to `/usr/local/bin/7z` when running outside a bundle (e.g. tests).
    static func binaryPath() -> String? {
        if let bundlePath = Bundle.main.path(forResource: "7z", ofType: nil) {
            return bundlePath
        }
        let fallbackPath = "/usr/local/bin/7z"
        if FileManager.default.fileExists(atPath: fallbackPath) {
            return fallbackPath
        }
        return nil
    }

    // MARK: - Compress

    /// Compress files or a directory into a .7z archive.
    /// - Parameters:
    ///   - inputPath: The file or folder to compress.
    ///   - outputPath: Destination path for the archive. If `nil`, places a `.7z` next to the input.
    ///   - progressHandler: Called with progress text lines from 7z stdout.
    /// - Returns: A `SevenZipResult` with the operation outcome.
    static func compress(
        inputPath: String,
        outputPath: String? = nil,
        progressHandler: ((String) -> Void)? = nil
    ) async throws -> SevenZipResult {
        guard let binary = binaryPath() else {
            throw WrapperError.binaryNotFound
        }

        let destination = outputPath ?? defaultArchivePath(for: inputPath)

        // 7z a <archive> <source> -y
        let arguments = ["a", destination, inputPath, "-y"]
        return try await runProcess(binary: binary, arguments: arguments, progressHandler: progressHandler)
    }

    // MARK: - Decompress

    /// Decompress an archive to a directory.
    /// - Parameters:
    ///   - archivePath: Path to the archive file.
    ///   - outputDirectory: Target extraction directory. If `nil`, extracts alongside the archive.
    ///   - progressHandler: Called with progress text lines from 7z stdout.
    /// - Returns: A `SevenZipResult` with the operation outcome.
    static func decompress(
        archivePath: String,
        outputDirectory: String? = nil,
        progressHandler: ((String) -> Void)? = nil
    ) async throws -> SevenZipResult {
        guard let binary = binaryPath() else {
            throw WrapperError.binaryNotFound
        }

        let destination = outputDirectory ?? defaultExtractionDirectory(for: archivePath)

        // 7z x <archive> -o<output> -y
        let arguments = ["x", archivePath, "-o\(destination)", "-y"]
        return try await runProcess(binary: binary, arguments: arguments, progressHandler: progressHandler)
    }

    // MARK: - Private Helpers

    /// Build a default `.7z` archive path next to the input file/folder.
    private static func defaultArchivePath(for inputPath: String) -> String {
        let url = URL(fileURLWithPath: inputPath)
        let name = url.deletingPathExtension().lastPathComponent
        let parent = url.deletingLastPathComponent().path
        return (parent as NSString).appendingPathComponent("\(name).7z")
    }

    /// Build a default extraction directory next to the archive.
    private static func defaultExtractionDirectory(for archivePath: String) -> String {
        let url = URL(fileURLWithPath: archivePath)
        let name = url.deletingPathExtension().lastPathComponent
        let parent = url.deletingLastPathComponent().path
        return (parent as NSString).appendingPathComponent(name)
    }

    /// Run the 7z binary as a subprocess and capture output.
    private static func runProcess(
        binary: String,
        arguments: [String],
        progressHandler: ((String) -> Void)?
    ) async throws -> SevenZipResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: binary)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        var stdoutData = Data()
        var stderrData = Data()

        // Stream stdout for progress updates
        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.isEmpty { return }
            stdoutData.append(data)
            if let line = String(data: data, encoding: .utf8) {
                progressHandler?(line)
            }
        }

        stderrPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if !data.isEmpty {
                stderrData.append(data)
            }
        }

        try process.run()
        process.waitUntilExit()

        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        stderrPipe.fileHandleForReading.readabilityHandler = nil

        let output = String(data: stdoutData, encoding: .utf8) ?? ""
        let errorOutput = String(data: stderrData, encoding: .utf8) ?? ""
        let exitCode = process.terminationStatus

        return SevenZipResult(
            success: exitCode == 0,
            output: output,
            errorOutput: errorOutput,
            exitCode: exitCode
        )
    }
}
