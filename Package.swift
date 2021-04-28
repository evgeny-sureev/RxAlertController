// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "RxAlertController",
    products: [
        .library(
            name: "RxAlertController",
            targets: ["RxAlertController"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        .target(name: "RxAlertController", dependencies: ["RxSwift"], path: "RxAlertController/Classes")
    ]
)
