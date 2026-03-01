import SwiftUI

@main
struct Mac7ZipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 480, minHeight: 360)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 520, height: 400)
    }
}
