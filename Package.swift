// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MegaNotch",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "MegaNotch", path: "Sources/MegaNotch")
    ]
)
