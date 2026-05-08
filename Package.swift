// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FloatRatingKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "FloatRatingKit",
            targets: ["FloatRatingKit"]
        )
    ],
    targets: [
        .target(
            name: "FloatRatingKit",
            path: "Sources"
        )
    ]
)
