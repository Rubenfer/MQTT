// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MQTT",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(name: "MQTT", targets: ["MQTT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/swift-server-community/mqtt-nio.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "MQTT",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "MQTTNIO", package: "mqtt-nio"),
            ]),
        .testTarget(
            name: "MQTTTests",
            dependencies: [
                .target(name: "MQTT"),
                .product(name: "XCTVapor", package: "vapor"),
            ]),
    ]
)
