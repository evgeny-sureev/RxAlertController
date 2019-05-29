//
//  ViewController.swift
//  RxAlertController
//
//  Created by evgeny-sureev on 03/31/2017.
//  Copyright (c) 2017 evgeny-sureev. All rights reserved.
//

import UIKit
import RxSwift
import RxAlertController

enum ExampleAction: String, CaseIterable {
    case simple = "Show simple alert with one button"
    case choice = "Show alert with two buttons"
    case select = "Present alert as action sheet (iPhone)"
    case popover = "Present alert in a popover (iPad)"
    case dismiss = "Dismiss alert observable afer some time"
    case complex = "Show alert with text fields and buttons"
    case prompt = "Ask user for value"
    case retry = "Error message with retry button"
}

class ViewController: UIViewController {
    
    var bag = DisposeBag()

    override func viewDidLoad() {
        var prev: UIButton? = nil
        for example in ExampleAction.allCases {
            prev = addButton(forAction: example, after: prev)
        }
    }
    
    func addButton(forAction action:ExampleAction, after view: UIView?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(action.rawValue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        self.view.addConstraints([
            NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: view ?? self.view, attribute: .top, multiplier: 1, constant: 50)
        ])
        button.addTarget(self, action: #selector(exampleAction), for: .touchUpInside)
        return button
    }
    
    @objc func exampleAction(sender: UIButton) {
        guard let example = ExampleAction(rawValue: sender.title(for: .normal)!) else {
            return
        }
        switch example {
        case .simple:
            UIAlertController.rx.show(in: self, title: "Test", message: "Hello", closeTitle: "Dismiss")
                .subscribe(onSuccess: {
                    print("Dialog dismissed")
                })
                .disposed(by: bag)
            
        case .choice:
            UIAlertController.rx.show(in: self, title: "Test", message: "Hello", buttonTitles: ["Cancel", "OK"])
                .subscribe(onSuccess: { button in
                    print("Clicked button \(button)")
                })
                .disposed(by: bag)
            
        case .select:
            UIAlertController.rx.show(in: self, title: "Change avatar", message: "Select source", buttons: [.default("Take a picture"), .default("Select from gallery"), .cancel("Cancel")], preferredStyle: .actionSheet)
                .subscribe(onSuccess: { button in
                    print("Selected option #\(button)")
                })
                .disposed(by: bag)
            
        case .dismiss:
            let dialog = UIAlertController.rx.show(in: self, title: "Wait 3 sec", message: nil, buttonTitles: [])
            
            class ResourceFactory: Disposable {
                
                let disposable: Disposable
                
                init(_ resource: Single<Int>) {
                    disposable = resource.subscribe()
                }
                
                func dispose() {
                    disposable.dispose()
                }
            }
            
            Observable.using({
                    return ResourceFactory(dialog)
                }, observableFactory: { _ in
                    return Observable<Void>.just(()).delay(.seconds(3), scheduler: MainScheduler.instance)
                })
                .subscribe()
                .disposed(by: bag)
            
        case .complex:
            UIAlertController.rx.show(in: self, title: "Login", message: "Please, fill this form",
                                      buttons: [.default("Login"), .destructive("Forgot Password"), .cancel("Cancel")],
                                      textFields: [{(textfield:UITextField) -> Void in textfield.placeholder = "Login"},
                                                   {(textfield:UITextField) -> Void in textfield.placeholder = "Password"; textfield.isSecureTextEntry = true}])
                .subscribe(onSuccess: { action in
                    print(action)
                })
                .disposed(by: bag)
            
        case .prompt:
            UIAlertController.rx.prompt(in: self, title: nil, message: "Enter your name", defaultValue: "Arnold", closeTitle: "Cancel", confirmTitle: "OK")
                .subscribe(onSuccess: { name in
                    print("Hey \(name)!")
                })
                .disposed(by: bag)
            
        case .retry:
            someNetworkFunctionThatMayFail()
                .retryWhen({ (error) -> Observable<Int> in
                    return error.flatMap({ [unowned self] error -> Maybe<Int> in
                        return UIAlertController.rx.show(in: self, title: "Error", message: error.localizedDescription, buttonTitles: ["Retry", "Abort"])
                            .filter({value in value == 0})
                    })
                })
                .flatMap { [unowned self] _ -> Single<Void> in
                    return UIAlertController.rx.show(in: self, title: "Save completed!", message: nil, closeTitle: "Ok")
                }
                .subscribe()
                .disposed(by: bag)
            
        case .popover:
            let alertController = UIAlertController(title: "Change avatar", message: "Select source", preferredStyle: .actionSheet)
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = sender
                popoverController.sourceRect = sender.bounds
            }

            alertController.rx.show(in: self, buttons: [.default("Take a picture"), .default("Select from gallery"), .cancel("Cancel")])
                .subscribe(onSuccess: { button in
                    print("Selected option #\(button)")
                })
                .disposed(by: bag)
        }
    }
    
    var counter = 0
    func someNetworkFunctionThatMayFail() -> Observable<Void> {
        return Observable<Void>.just(())
            .delay(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMap({ [unowned self] _ -> Observable<Void> in
                if self.counter < 2 {
                    self.counter += 1
                    return Observable.error(NSError(domain: "RxAlertControllerTest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Error saving scores"]))
                } else {
                    self.counter = 0
                    return Observable.just(())
                }
            })
    }
}

