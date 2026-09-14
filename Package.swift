// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "tomato-timer",
    platforms: [
        .macOS(.v13),
    ],
    targets: [
        .executableTarget(
            name: "tomato_timer"
        ),
    ]
)