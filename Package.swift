// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AdventOfCode2025",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(name: "day01", targets: ["day01"]),
        .executable(name: "day02", targets: ["day02"]),
        .executable(name: "day03", targets: ["day03"]),
        .executable(name: "day04", targets: ["day04"]),
        .executable(name: "day05", targets: ["day05"]),
        .executable(name: "day06", targets: ["day06"]),
        .executable(name: "day07", targets: ["day07"]),
        .executable(name: "day08", targets: ["day08"]),
        .executable(name: "day09", targets: ["day09"]),
        .executable(name: "day10", targets: ["day10"]),
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
        .executableTarget(
            name: "day06",
            dependencies: ["Shared"],
            path: "Sources/day06",
            resources: [
                .copy("input.txt")
            ]
        ),
        .executableTarget(
            name: "day07",
            dependencies: ["Shared"],
            path: "Sources/day07",
            resources: [
                .copy("input.txt")
            ]
        ),
        .executableTarget(
            name: "day08",
            dependencies: ["Shared"],
            path: "Sources/day08",
            resources: [
                .copy("input.txt")
            ]
        ),
        .executableTarget(
            name: "day09",
            dependencies: ["Shared"],
            path: "Sources/day09",
            resources: [
                .copy("input.txt")
            ]
        ),
        .executableTarget(
            name: "day10",
            dependencies: ["Shared"],
            path: "Sources/day10",
            resources: [
                .copy("input.txt")
            ]
        ),
    ]
)