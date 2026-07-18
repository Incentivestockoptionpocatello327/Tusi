// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Tusi",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Tusi",
            path: "Sources/Tusi"
        )
    ]
)
