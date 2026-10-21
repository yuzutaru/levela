// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Nutrition",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "Nutrition", targets: ["Nutrition"])
    ],
    dependencies: [
        .package(path: "../Design"),
        .package(path: "../Summary")
    ],
    targets: [
        .target(
            name: "Nutrition",
            dependencies: [
                .product(name: "Design", package: "Design"),
                .product(name: "Summary", package: "Summary")
            ]
        ),
        .testTarget(
            name: "NutritionTests",
            dependencies: ["Nutrition"]
        )
    ],
    swiftLanguageModes: [.v5]
)
