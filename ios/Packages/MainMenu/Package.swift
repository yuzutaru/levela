// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MainMenu",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "MainMenu", targets: ["MainMenu"])
    ],
    dependencies: [
        .package(path: "../Design")
    ],
    targets: [
        .target(
            name: "MainMenu",
            dependencies: [
                .product(name: "Design", package: "Design")
            ]
        ),
        .testTarget(
            name: "MainMenuTests",
            dependencies: ["MainMenu"]
        )
    ],
    swiftLanguageModes: [.v5]
)
