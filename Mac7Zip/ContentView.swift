import SwiftUI

/// Main application content view hosting the drop zone.
struct ContentView: View {
    @StateObject private var viewModel = ArchiveViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Title bar area
            HStack {
                Image(systemName: "archivebox.fill")
                    .foregroundColor(.accentColor)
                Text("Mac7Zip")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Drop zone fills remaining space
            DropZoneView(viewModel: viewModel)
                .padding()
        }
    }
}
