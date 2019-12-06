// swift-tools-version:5.1

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
        .package(url: "git@github.com:ReactiveX/RxSwift.git", from: "5.0.0")
    ],
    targets: [
        .target(name: "RxAlertController", dependencies: ["RxSwift"], path: "RxAlertController/Classes")
    ]
)
