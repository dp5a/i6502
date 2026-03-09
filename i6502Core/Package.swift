// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "i6502Core",
    products: [
        .executable(
            name: "i6502CLI",
            targets: ["i6502CLI"]
        ),
        .library(
            name: "i6502Assembler",
            targets: ["i6502Assembler"]
        ),
        .library(
            name: "i6502Emulator",
            targets: ["i6502Emulator"]
        ),
        .library(
            name: "i6502Specification",
            targets: ["i6502Specification"]
        )
    ],
    targets: [
        .executableTarget(
            name: "i6502CLI",
            dependencies: ["i6502Assembler"],
            path: "Sources/Main"
        ),
        .target(
            name: "i6502Assembler",
            dependencies: ["i6502Specification"],
            path: "Sources/Assembler"
        ),
        .target(
            name: "i6502Emulator",
            dependencies: ["i6502Specification"],
            path: "Sources/Emulator"
        ),
        .target(
            name: "i6502Specification",
            path: "Sources/Specification"
        )
    ]
)
