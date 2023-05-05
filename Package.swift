// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SchedJoulesSDK",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SchedJoulesSDK",
            targets: ["SchedJoulesSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/schedjoules/swift-api-client.git",
                 branch: "SwiftPackage"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SchedJoulesSDK",
            dependencies: [.product(name: "SchedJoulesApiClient", package: "swift-api-client"),
                           .product(name: "SDWebImage", package: "SDWebImage")]),
        .testTarget(
            name: "SchedJoulesSDKTests",
            dependencies: ["SchedJoulesSDK",
                           .product(name: "SchedJoulesApiClient", package: "swift-api-client"),
                           .product(name: "SDWebImage", package: "SDWebImage")]),
    ]
)
