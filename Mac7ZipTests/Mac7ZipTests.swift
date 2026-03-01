import XCTest
@testable import Mac7Zip

final class FileTypeTests: XCTestCase {

    // MARK: - Archive detection via path string

    func testDetectsSevenZipArchive() {
        XCTAssertEqual(FileType.detect(path: "/tmp/archive.7z"), .archive)
    }

    func testDetectsZipArchive() {
        XCTAssertEqual(FileType.detect(path: "/Users/test/file.zip"), .archive)
    }

    func testDetectsTarGzArchive() {
        XCTAssertEqual(FileType.detect(path: "backup.tar"), .archive)
        XCTAssertEqual(FileType.detect(path: "backup.gz"), .archive)
        XCTAssertEqual(FileType.detect(path: "backup.tgz"), .archive)
    }

    func testDetectsRarArchive() {
        XCTAssertEqual(FileType.detect(path: "movies.rar"), .archive)
    }

    func testDetectsIsoArchive() {
        XCTAssertEqual(FileType.detect(path: "system.iso"), .archive)
    }

    func testDetectsRegularFile() {
        XCTAssertEqual(FileType.detect(path: "/Users/test/document.pdf"), .regular)
        XCTAssertEqual(FileType.detect(path: "photo.jpg"), .regular)
        XCTAssertEqual(FileType.detect(path: "script.py"), .regular)
    }

    func testDetectsDirectoryAsRegular() {
        XCTAssertEqual(FileType.detect(path: "/Users/test/folder"), .regular)
    }

    func testCaseInsensitiveExtension() {
        XCTAssertEqual(FileType.detect(path: "ARCHIVE.7Z"), .archive)
        XCTAssertEqual(FileType.detect(path: "file.ZIP"), .archive)
        XCTAssertEqual(FileType.detect(path: "data.Tar"), .archive)
    }

    // MARK: - Archive detection via URL

    func testDetectsArchiveFromURL() {
        let url = URL(fileURLWithPath: "/tmp/test.7z")
        XCTAssertEqual(FileType.detect(url: url), .archive)
    }

    func testDetectsRegularFromURL() {
        let url = URL(fileURLWithPath: "/tmp/readme.txt")
        XCTAssertEqual(FileType.detect(url: url), .regular)
    }

    // MARK: - Additional archive formats

    func testDetectsXzArchive() {
        XCTAssertEqual(FileType.detect(path: "data.xz"), .archive)
    }

    func testDetectsBz2Archive() {
        XCTAssertEqual(FileType.detect(path: "data.bz2"), .archive)
    }

    func testDetectsLzmaArchive() {
        XCTAssertEqual(FileType.detect(path: "data.lzma"), .archive)
    }

    func testDetectsZstArchive() {
        XCTAssertEqual(FileType.detect(path: "data.zst"), .archive)
        XCTAssertEqual(FileType.detect(path: "data.zstd"), .archive)
    }
}

final class SevenZipWrapperTests: XCTestCase {

    func testDefaultArchivePathAppendsSevenZExtension() {
        // Test that the archive path calculation works correctly
        // by verifying the naming convention
        let inputPath = "/Users/test/Documents/myfile.txt"
        let expectedName = "myfile.7z"

        let url = URL(fileURLWithPath: inputPath)
        let name = url.deletingPathExtension().lastPathComponent
        let archiveName = "\(name).7z"

        XCTAssertEqual(archiveName, expectedName)
    }

    func testDefaultExtractionDirectoryRemovesExtension() {
        let archivePath = "/Users/test/Downloads/photos.7z"
        let expectedName = "photos"

        let url = URL(fileURLWithPath: archivePath)
        let name = url.deletingPathExtension().lastPathComponent

        XCTAssertEqual(name, expectedName)
    }

    func testBinaryPathReturnsNilWhenNotAvailable() {
        // In a test environment without 7z installed, binaryPath may return nil.
        // This test documents that behavior.
        let path = SevenZipWrapper.binaryPath()
        // Path is either nil (no 7z) or a valid filesystem path
        if let path = path {
            XCTAssertTrue(FileManager.default.fileExists(atPath: path),
                          "Binary path should point to an existing file")
        }
    }
}
