// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AdventOfCode2025",
    platforms: [
        .macOS(.v26)     // ← lägg till detta
    ],
    products: [
        .executable(name: "day01", targets: ["day01"]),
        .executable(name: "day02", targets: ["day02"]),
    ],
    targets: [
        .target(
            name: "Shared",
            path: "Sources/Shared"
        ),
        .executableTarget(
            name: "day01",
            dependencies: ["Shared"],
            path: "Sources/day01",
            resources: [
                .copy("input.txt")
            ]
        ),
        .executableTarget(
            name: "day02",
            dependencies: ["Shared"],
            path: "Sources/day02",
            resources: [
                .copy("input.txt")
            ]
        ),
        .executableTarget(
            name: "day03",
            dependencies: ["Shared"],
            path: "Sources/day03",
            resources: [
                .copy("input.txt")
            ]
        ),
        .executableTarget(
            name: "day04",
            dependencies: ["Shared"],
            path: "Sources/day04",
            resources: [
                .copy("input.txt")
            ]
        ),
        .executableTarget(
            name: "day05",
            dependencies: ["Shared"],
            path: "Sources/day05",
            resources: [
                .copy("input.txt")
            ]
        ),
    ]
)