# RxAlertController

[![CI Status](http://img.shields.io/travis/evgeny-sureev/RxAlertController.svg?style=flat)](https://travis-ci.org/evgeny-sureev/RxAlertController)
[![Version](https://img.shields.io/cocoapods/v/RxAlertController.svg?style=flat)](http://cocoapods.org/pods/RxAlertController)
[![License](https://img.shields.io/cocoapods/l/RxAlertController.svg?style=flat)](http://cocoapods.org/pods/RxAlertController)
[![Platform](https://img.shields.io/cocoapods/p/RxAlertController.svg?style=flat)](http://cocoapods.org/pods/RxAlertController)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

I'm tired of copying same file into the project every time I need to display a message in the application, so I decided to create a pod.

## Changelog

- `2.1` Add Carthage support
- `2.0` Move to Swift 4
- `1.1` Add methods to display already instantiated alert controller 

## Introduction

RxAlertController allows you to display messages on the screen, using the sequence of RxSwift observable streams instead of traditional closures.
Thus, the dialog box can be chained with other observables, for example, as follows:


```swift
api.someNetworkFunctionThatMayFail()
.retryWhen({ (error) -> Observable<Int> in
    return error.flatMap({ error -> Observable<Int> in
        return UIAlertController.rx.show(in: self, title: "Error", message: error.localizedDescription, buttonTitles: ["Retry", "Abort"])
            .filter({value in value == 0})
    })
})
.subscribe(onNext, onError, etc)
```

And using [UIImagePickerController+RxCreate](https://github.com/ReactiveX/RxSwift/blob/master/RxExample/RxExample/Examples/ImagePicker) from RxSwift examples, you can choose pictures like this:


```swift
UIAlertController.rx.show(in: self,
                       title: "Change avatar", 
                     message: "Select source", 
                     buttons: [.default("Take a picture"), .default("Select from gallery"), .cancel("Cancel")],
              preferredStyle: .actionSheet)
    .flatMap({ choice in
        if choice == 0 {
            // Create and return UIImagePickerController with source type camera
            return UIImagePickerController.rx.createWithParent(self) { picker in
                picker.sourceType = .camera
                picker.allowsEditing = false
            }
        } else {
            // Create and return UIImagePickerController with source type photo library
            return UIImagePickerController.rx.createWithParent(self) { picker in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = false
            }
        }
    })
    .flatMap { $0.rx.didFinishPickingMediaWithInfo }
    .map { info in
        return info[UIImagePickerControllerOriginalImage] as? UIImage
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
