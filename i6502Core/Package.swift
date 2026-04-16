// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "i6502Core",
    products: [
        .executable(name: "i6502CLI", targets: ["i6502CLI"]),
        .library(name: "i6502Assembler", targets: ["i6502Assembler"]),
        .library(name: "i6502Emulator", targets: ["i6502Emulator"]),
        .library(name: "i6502Specification", targets: ["i6502Specification"])
    ],
    targets: [
        .executableTarget(
            name: "i6502CLI",
            dependencies: ["i6502Assembler", "i6502Emulator"],
            path: "Sources/Main",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .target(
            name: "i6502Assembler",
            dependencies: ["i6502Specification"],
            path: "Sources/Assembler",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .target(
            name: "i6502CEmulator",
            path: "Sources/CEmulator",
            cSettings: [
                .headerSearchPath("include"),
                .headerSearchPath("cpu_module"),
                .headerSearchPath("bus_module"),
                .headerSearchPath("emu_module"),
                .unsafeFlags(["-Og"], .when(configuration: .debug)),
                .unsafeFlags(["-O2"], .when(configuration: .release))
            ]
        ),
        .target(
            name: "i6502Emulator",
            dependencies: ["i6502Specification", "i6502CEmulator"],
            path: "Sources/Emulator",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .target(
            name: "i6502Specification",
            path: "Sources/Specification",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .testTarget(
            name: "i6502Tests",
            dependencies: ["i6502Specification", "i6502Assembler"],
            path: "Tests",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        )
    ]
)
