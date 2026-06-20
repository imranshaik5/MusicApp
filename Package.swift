// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MusicApp",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "MusicApp",
            path: "Sources/MusicApp",
            resources: [.copy("../../Resources")]
        )
    ]
)
