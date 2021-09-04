// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ron",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RonCore",
            targets: ["RonCore"]),
        .library(
            name: "RonRdt",
            targets: ["RonRdt"]),
        .library(
            name: "RonClock",
            targets: ["RonClock"]),
        .library(
            name: "RonClient",
            targets: ["RonClient"]),
        .library(
            name: "RonApi",
            targets: ["RonApi"]),
        .library(
            name: "RonCore-xx",
            targets: ["RonCore-xx"]),
        .library(
            name: "RonRdt-xx",
            targets: ["RonRdt-xx"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RonCore",
            dependencies: []),
        .testTarget(
            name: "RonCoreTests",
            dependencies: ["RonCore"]),
        .target(
            name: "RonRdt",
            dependencies: ["RonCore"]),
        .testTarget(
            name: "RonRdtTests",
            dependencies: ["RonRdt"]),
        .target(
            name: "RonClock",
            dependencies: ["RonCore"]),
        .testTarget(
            name: "RonClockTests",
            dependencies: ["RonClock"]),
        .target(
            name: "RonClient",
            dependencies: ["RonCore", "RonRdt", "RonClock",]),
        .testTarget(
            name: "RonClientTests",
            dependencies: ["RonClient",],
            resources: [.process("Resources")]
        ),
        .target(
            name: "RonApi",
            dependencies: ["RonClient",]),
        .testTarget(
            name: "RonApiTests",
            dependencies: ["RonApi"],
            resources: [.process("Resources")]),
        .target(
            name: "RonCore-xx",
            dependencies: []),
        .testTarget(
            name: "RonCore-xxTests",
            dependencies: ["RonCore-xx"]),
        .target(
            name: "RonRdt-xx",
            dependencies: ["RonCore-xx",]),
        .testTarget(
            name: "RonRdt-xxTests",
            dependencies: ["RonRdt-xx",]),
    ]
)
