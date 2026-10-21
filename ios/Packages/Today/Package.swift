// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Today",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "Today", targets: ["Today"])
    ],
    dependencies: [
        .package(path: "../Design")
    ],
    targets: [
        .target(
            name: "Today",
            dependencies: [
                .product(name: "Design", package: "Design")
            ]
        ),
        .testTarget(
            name: "TodayTests",
            dependencies: ["Today"]
        )
    ],
    swiftLanguageModes: [.v5]
)
