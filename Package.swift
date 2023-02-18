// Swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SWAPI",
    products: [
        .library(
            name: "SWAPI",
            targets: ["SWAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0")),
    ],
    targets: [
        .target(
            name: "SWAPI",
            dependencies: ["Swifter"]),
    ]
)
