import SwiftUI
import UniformTypeIdentifiers

/// A visual drop zone that accepts file drops and triggers compress/decompress.
struct DropZoneView: View {
    @ObservedObject var viewModel: ArchiveViewModel
    @State private var isTargeted = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    style: StrokeStyle(lineWidth: 3, dash: [10])
                )
                .foregroundColor(isTargeted ? .accentColor : .secondary.opacity(0.5))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isTargeted ? Color.accentColor.opacity(0.08) : Color.clear)
                )

            dropContent
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
        .animation(.easeInOut(duration: 0.2), value: isTargeted)
    }

    @ViewBuilder
    private var dropContent: some View {
        switch viewModel.state {
        case .idle:
            VStack(spacing: 12) {
                Image(systemName: "arrow.down.doc.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("Drop files here")
                    .font(.title2)
                    .foregroundColor(.primary)
                Text("Archives will be extracted.\nOther files will be compressed to .7z.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()

        case .processing(let description):
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text(description)
                    .font(.headline)
                if !viewModel.progressText.isEmpty {
                    Text(viewModel.progressText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .truncationMode(.middle)
                }
            }
            .padding()

        case .success(let message):
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)
                Text(message)
                    .font(.headline)
                Button("Done") {
                    viewModel.reset()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

        case .failure(let message):
            VStack(spacing: 12) {
                Image(systemName: "xmark.octagon.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
                Text("Error")
                    .font(.headline)
                Text(message)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                Button("Try Again") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        var urls: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    urls.append(url)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if !urls.isEmpty {
                viewModel.handleDroppedURLs(urls)
            }
        }
    }
}
