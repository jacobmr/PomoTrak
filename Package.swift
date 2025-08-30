// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PomoTrak",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "PomoTrak", targets: ["PomoTrak"])
    ],
    dependencies: [
        // Add any dependencies here
    ],
    targets: [
        .executableTarget(
            name: "PomoTrak",
            dependencies: [],
            path: "Sources/PomoTrak"
        )
    ]
)
