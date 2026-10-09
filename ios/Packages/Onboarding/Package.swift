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
        .package(path: "../Design")
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
            dependencies: ["Onboarding"]
        )
    ],
    swiftLanguageModes: [.v5]
)
