// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Design",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "Design", targets: ["Design"])
    ],
    targets: [
        .target(
            name: "Design",
            resources: [
                .process("Resources")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
