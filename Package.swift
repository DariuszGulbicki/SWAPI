// Swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SWAPI",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SWAPI",
            targets: ["SWAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/DariuszGulbicki/logging-camp.git", .upToNextMajor(from: "1.0.0")) 
    ],
    targets: [
        .target(
            name: "SWAPI",
            dependencies: [
                .product(name: "Swifter", package: "swifter"),
                .product(name: "LoggingCamp", package: "logging-camp")
                ]),
    ]
)
