// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DNSPodDDNS",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .executable(name: "DNSPodDDNS", targets: ["DNSPodDDNS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/zhtut/async-network.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ... "4.0.0"),
        .package(url: "https://github.com/zhtut/UtilCore.git", "1.0.0" ... "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "DNSPodDDNS",
            dependencies: [
                .product(name: "AsyncNetwork", package: "async-network"),
                .product(name: "Crypto", package: "swift-crypto"),
                "UtilCore"
            ], 
            path: "Sources/DNSPodDDNS"
        ),
        .testTarget(name: "DDNSTests", dependencies: [
            "DNSPodDDNS"
        ])
    ]
)
