// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SmallCount",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "SmallCount", targets: ["SmallCount"])
    ],
    targets: [
        .executableTarget(
            name: "SmallCount",
            path: "Sources",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "SmallCountTests",
            dependencies: ["SmallCount"],
            path: "Tests",
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
