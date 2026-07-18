// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Tusi",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Tusi",
            path: "Sources/Tusi",
            // .copy, not .process: these ship straight into the .app's top-level
            // Resources by build.sh (not via SwiftPM's own resource bundle), so nothing
            // needs SwiftPM's asset-catalog-style processing.
            resources: [.copy("Resources")]
        )
    ]
)
