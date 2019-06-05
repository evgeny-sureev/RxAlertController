# RxAlertController

[![CI Status](http://img.shields.io/travis/evgeny-sureev/RxAlertController.svg?style=flat)](https://travis-ci.org/evgeny-sureev/RxAlertController)
[![Version](https://img.shields.io/cocoapods/v/RxAlertController.svg?style=flat)](http://cocoapods.org/pods/RxAlertController)
[![License](https://img.shields.io/cocoapods/l/RxAlertController.svg?style=flat)](http://cocoapods.org/pods/RxAlertController)
[![Platform](https://img.shields.io/cocoapods/p/RxAlertController.svg?style=flat)](http://cocoapods.org/pods/RxAlertController)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

I'm tired of copying same file into the project every time I need to display a message in the application, so I decided to create a pod.

## Changelog

- `5.0` Migrate to Swift 5 and RxSwift 5.0
- `4.0` Migrate to Swift 4.2
- `3.0` Convert return values from `Observable`s to `Single` and `Maybe`
- `2.1` Add Carthage support
- `2.0` Move to Swift 4
- `1.1` Add methods to display already instantiated alert controller 

## Introduction

RxAlertController allows you to display messages on the screen, using the sequence of RxSwift observable streams instead of traditional closures.
Thus, the dialog box can be chained with other observables, for example, as follows:


```swift
api.someNetworkFunctionThatMayFail()
.retryWhen({ (error) -> Observable<Int> in
    return error.flatMap({ error -> Maybe<Int> in
        return UIAlertController.rx.show(in: self, title: "Error", message: error.localizedDescription, buttonTitles: ["Retry", "Abort"])
            .filter({value in value == 0})
    })
})
.subscribe(onNext, onError, etc)
```

And using [RxMediaPicker](https://github.com/RxSwiftCommunity/RxMediaPicker) from RxSwiftCommunity, you can choose pictures like this:


```swift
UIAlertController.rx.show(in: self,
                       title: "Change avatar", 
                     message: "Select source", 
                     buttons: [.default("Take a picture"), .default("Select from gallery"), .cancel("Cancel")],
              preferredStyle: .actionSheet)
    .flatMap({ [unowned self] choice in
        if choice == 0 {
            return self.picker.takePhoto()
        } else {
            return self.picker.selectImage(source: .photoLibrary)
        }
    })
    .map { (original, edited) -> UIImage in
        return original
    }
    .bind(to: imageView.rx.image)
    .disposed(by: disposeBag)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

RxSwift is required, obviously.

## Installation

RxAlertController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RxAlertController"
```

Also you can use [Carthage](https://github.com/Carthage/Carthage). To install it, add line to Cartfile:

```ruby
github "evgeny-sureev/RxAlertController"
```

## Author

Evgeny Sureev, u@litka.ru

## License

RxAlertController is available under the Apache License 2.0. See the LICENSE file for more info.
