// swift-tools-version:5.2

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
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(name: "RxAlertController", dependencies: ["RxSwift"], path: "RxAlertController/Classes")
    ]
)
