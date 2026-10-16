// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Profile",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "Profile", targets: ["Profile"])
    ],
    targets: [
        .target(name: "Profile"),
        .testTarget(
            name: "ProfileTests",
            dependencies: ["Profile"]
        )
    ],
    swiftLanguageModes: [.v5]
)
