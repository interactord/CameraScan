// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CameraScan",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "CameraScan",
      targets: ["CameraScan"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "CameraScan",
      dependencies: []),
    .testTarget(
      name: "CameraScanTests",
      dependencies: ["CameraScan"]),
  ])
