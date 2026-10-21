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
        .package(path: "../Design"),
        .package(path: "../Summary")
    ],
    targets: [
        .target(
            name: "MainMenu",
            dependencies: [
                .product(name: "Design", package: "Design"),
                .product(name: "Summary", package: "Summary")
            ]
        ),
        .testTarget(
            name: "MainMenuTests",
            dependencies: ["MainMenu"]
        )
    ],
    swiftLanguageModes: [.v5]
)
