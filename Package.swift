// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GalleryPager",
    platforms: [.iOS(.v14), .macOS(.v10_14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GalleryPager",
            targets: ["GalleryPager"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.7.0")),
        .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", .upToNextMajor(from: "0.9.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GalleryPager",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect")
            ]
        )
    ]
)
