// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Summary",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "Summary", targets: ["Summary"])
    ],
    dependencies: [
        .package(path: "../Design")
    ],
    targets: [
        .target(
            name: "Summary",
            dependencies: [
                .product(name: "Design", package: "Design")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
