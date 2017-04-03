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

enum ExampleAction: String {
    case simple = "Show simple alert with one button"
    case choice = "Show alert with two buttons"
    case select = "Present alert as action sheet"
    case dismiss = "Dismiss alert observable afer some time"
    case complex = "Show alert with text fields and buttons"
    case prompt = "Ask user for value"
}

/// Iterate enum by user rintaro @ http://stackoverflow.com/a/28341290/5887605
func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}

class ViewController: UIViewController {
    
    var bag = DisposeBag()

    override func viewDidLoad() {
        var prev: UIButton? = nil
        for example in iterateEnum(ExampleAction.self) {
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
    
    func exampleAction(sender: UIButton) {
        guard let example = ExampleAction(rawValue: sender.title(for: .normal)!) else {
            return
        }
        switch example {
        case .simple:
            UIAlertController.rx.show(in: self, title: "Test", message: "Hello", closeTitle: "Dismiss")
                .subscribe(onNext: {
                    print("Dialog dismissed")
                })
                .addDisposableTo(bag)
            
        case .choice:
            UIAlertController.rx.show(in: self, title: "Test", message: "Hello", buttonTitles: ["Cancel", "OK"])
                .subscribe(onNext: { button in
                    print("Clicked button \(button)")
                })
                .addDisposableTo(bag)
            
        case .select:
            UIAlertController.rx.show(in: self, title: "Change avatar", message: "Select source", buttons: [.default("Take a picture"), .default("Select from gallery"), .cancel("Cancel")], preferredStyle: .actionSheet)
                .subscribe(onNext: { button in
                    print("Selected option #\(button)")
                })
                .addDisposableTo(bag)
            
        case .dismiss:
            let dialog = UIAlertController.rx.show(in: self, title: "Wait 3 sec", message: nil, buttonTitles: [])
            
            class ResourceFactory: Disposable {
                
                let disposable: Disposable
                
                init(_ resource: Observable<Int>) {
                    disposable = resource.subscribe()
                }
                
                func dispose() {
                    disposable.dispose()
                }
            }
            
            Observable<Void>.using( {
                    return ResourceFactory(dialog)
                }, observableFactory: { _ in
                    return Observable<Void>.just().delay(3, scheduler: MainScheduler.instance)
                })
                .subscribe().addDisposableTo(bag)
            
        case .complex:
            UIAlertController.rx.show(in: self, title: "Login", message: "Please, fill this form",
                                      buttons: [.default("Login"), .destructive("Forgot Password"), .cancel("Cancel")],
                                      textFields: [{(textfield:UITextField) -> Void in textfield.placeholder = "Login"},
                                                   {(textfield:UITextField) -> Void in textfield.placeholder = "Password"; textfield.isSecureTextEntry = true}])
                .subscribe(onNext: { action in
                    print(action)
                })
                .addDisposableTo(bag)
            
        case .prompt:
            UIAlertController.rx.prompt(in: self, title: nil, message: "Enter your name", defaultValue: "Arnold", closeTitle: "Cancel", confirmTitle: "OK")
                .subscribe(onNext: { name in
                    print("Hey \(name)!")
                })
                .addDisposableTo(bag)
        }
    }
}

