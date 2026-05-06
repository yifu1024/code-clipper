// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "CodeClipper",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "CodeClipper", targets: ["CodeClipper"])
    ],
    targets: [
        .executableTarget(
            name: "CodeClipper",
            linkerSettings: [
                .linkedLibrary("sqlite3")
            ]
        )
    ]
)
