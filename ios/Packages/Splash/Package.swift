// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Splash",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "Splash", targets: ["Splash"])
    ],
    dependencies: [
        .package(path: "../Design")
    ],
    targets: [
        .target(
            name: "Splash",
            dependencies: [
                .product(name: "Design", package: "Design")
            ]
        ),
        .testTarget(
            name: "SplashTests",
            dependencies: ["Splash"]
        )
    ],
    swiftLanguageModes: [.v5]
)
