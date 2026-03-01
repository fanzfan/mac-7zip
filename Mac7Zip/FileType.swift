import Foundation

/// Supported archive extensions recognized by the app.
enum FileType {
    case archive
    case regular

    /// Archive file extensions that 7-Zip can decompress.
    static let archiveExtensions: Set<String> = [
        "7z", "zip", "gz", "gzip", "bz2", "bzip2", "xz",
        "tar", "tgz", "tbz2", "txz", "rar", "cab", "iso",
        "lzma", "lzh", "arj", "cpio", "rpm", "deb", "wim",
        "z", "lz", "lz4", "zst", "zstd"
    ]

    /// Determine the file type based on its path extension.
    static func detect(path: String) -> FileType {
        let ext = (path as NSString).pathExtension.lowercased()
        return archiveExtensions.contains(ext) ? .archive : .regular
    }

    /// Determine the file type from a URL.
    static func detect(url: URL) -> FileType {
        let ext = url.pathExtension.lowercased()
        return archiveExtensions.contains(ext) ? .archive : .regular
    }
}
