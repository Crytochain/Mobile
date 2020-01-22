// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "chain3swift",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(name: "chain3swift", targets: ["chain3swift"])
    ],
  dependencies: [
    .package(url: "https://github.com/attaswift/BigInt.git", from: "3.1.0"),
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.12.0"),
    .package(url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.1"),
    .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.4.0"),
    ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "chain3swift",
      dependencies: ["BigInt", "CryptoSwift", "secp256k1", "PromiseKit"],
      path: "Sources",
      exclude: [
        "ObjectiveC",
        "Utils/EIP67Code.swift"
        ]),
    ]
)
