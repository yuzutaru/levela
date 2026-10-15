// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "Onboarding", targets: ["Onboarding"])
    ],
    dependencies: [
        .package(path: "../Design"),
        // Test-only: inspects the SwiftUI view tree from the unit tests.
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.5")
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                .product(name: "Design", package: "Design")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "OnboardingTests",
            dependencies: [
                "Onboarding",
                .product(name: "ViewInspector", package: "ViewInspector")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
