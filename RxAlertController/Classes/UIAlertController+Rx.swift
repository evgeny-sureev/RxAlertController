//
// Copyright (c) 2017 Evgeny Sureev <u@litka.ru>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import RxSwift
import UIKit

extension UIAlertController {
    public enum AlertButton {
        case `default`(String)
        case disabled(String)
        case cancel(String)
        case destructive(String)
    }
}

extension Reactive where Base: UIAlertController {
    
    public typealias TextFieldConfiguration = ((UITextField) -> Void)
    
    /// Creates and displays UIAlertController to the user.
    ///
    /// - parameter in: View Controller presenting alert
    /// - parameter title: Title of alert
    /// - parameter message: Message
    /// - parameter buttons: Array of alert button descriptions
    /// - parameter textFields: Array of alert text field configuration blocks
    /// - parameter preferredStyle: Alert's style
    /// - returns: `Observable<(Int, [String])>`, where first value in tuple is index of selected button and second is array of strings, entered in provided textfields (or empty if there are no text fields)
    
    public static func show(in vc: UIViewController, title: String?, message: String?, buttons:[UIAlertController.AlertButton], textFields: [TextFieldConfiguration?], preferredStyle: UIAlertControllerStyle = .alert) -> Observable<(Int, [String])> {
        return Observable<(Int, [String])>.create({ [weak vc] observer in
            guard let vc = vc else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            let alertView = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            
            for index in 0 ..< buttons.count {
                let handler = { [unowned alertView] (action:UIAlertAction) -> Void in
                    let texts:[String] = alertView.textFields?.map { $0.text ?? "" } ?? []
                    observer.on(.next((index, texts)))
                    observer.on(.completed)
                }
                
                let action: UIAlertAction
                switch buttons[index] {
                case .default(let title):
                    action = UIAlertAction(title: title, style: .default, handler: handler)
                case .cancel(let title):
                    action = UIAlertAction(title: title, style: .cancel, handler: handler)
                case .destructive(let title):
                    action = UIAlertAction(title: title, style: .destructive, handler: handler)
                case .disabled(let title):
                    action = UIAlertAction(title: title, style: .default, handler: handler)
                    action.isEnabled = false
                }
                alertView.addAction(action)
            }
            
            for textField in textFields {
                alertView.addTextField(configurationHandler: textField)
            }
            
            DispatchQueue.main.async(execute: {
                vc.present(alertView, animated: true, completion: nil)
            })
            
            return Disposables.create(with: {
                if alertView.presentingViewController != nil {
                    alertView.dismiss(animated: true, completion: nil)
                }
            })
        })
    }
    
    /// Creates and displays UIAlertController to the user.
    ///
    /// - parameter in: View Controller presenting alert
    /// - parameter title: Title of alert
    /// - parameter message: Message
    /// - parameter buttons: Array of alert button descriptions
    /// - parameter preferredStyle: Alert's style
    /// - returns: `Observable<Int>`, which emits index of selected button in `buttons` array
    
    public static func show(in vc: UIViewController, title: String?, message: String?, buttons:[UIAlertController.AlertButton], preferredStyle: UIAlertControllerStyle = .alert) -> Observable<Int> {
        return show(in: vc, title: title, message: message, buttons: buttons, textFields: [], preferredStyle: preferredStyle).map { $0.0 }
    }
    
    /// Creates and displays UIAlertController with many buttons to the user.
    ///
    /// First button in list created whith `UIAlertActionStyle.cancel` style.
    ///
    /// - parameter in: View Controller presenting alert
    /// - parameter title: Title of alert
    /// - parameter message: Message
    /// - parameter buttonTitles: Titles of alert buttons
    /// - parameter preferredStyle: Alert's style
    /// - returns: `Observable<Int>`, which emits index of selected button in `buttonTitles` array
    
    public static func show(in vc: UIViewController, title: String?, message: String?, buttonTitles:[String], preferredStyle: UIAlertControllerStyle = .alert) -> Observable<Int> {
        let buttons = buttonTitles.enumerated().map { (index, title) -> UIAlertController.AlertButton in
            if index == 0 {
                return .cancel(title)
            } else {
                return .default(title)
            }
        }
        return show(in: vc, title: title, message: message, buttons: buttons, textFields: [], preferredStyle: preferredStyle).map { $0.0 }
    }
    
    /// Creates and displays simple UIAlertController to the user.
    ///
    /// Alert controller has one button and is presented as `UIAlertControllerStyle.alert`.
    ///
    /// - parameter in: View Controller presenting alert
    /// - parameter title: Title of alert
    /// - parameter message: Message
    /// - parameter closeTitle: Title of close button
    /// - returns: `Observable<Void>`, which emits onNext after user closes alert
    
    public static func show(in vc: UIViewController, title: String?, message: String?, closeTitle: String) -> Observable<Void> {
        return show(in: vc, title: title, message: message, buttons: [.cancel(closeTitle)], textFields: []).map { _ in return }
    }
    
    /// Creates and displays UIAlertController asking user to enter value in text field.
    ///
    /// - parameter in: View Controller presenting alert
    /// - parameter title: Title of alert
    /// - parameter message: Message
    /// - parameter defaultValue: Default value of text field in alert
    /// - parameter closeTitle: Title of close button
    /// - parameter confirmTitle: Title of confirm button
    /// - returns: `Observable<String>`, emitting text that user has entered in alert, if user clicks confirmation button. If user clicks cancel button, stream completes without generating onNext events.
    
    public static func prompt(in vc: UIViewController, title: String?, message: String?, defaultValue: String?, closeTitle: String, confirmTitle: String) -> Observable<String> {
        return show(in: vc, title: title, message: message, buttons: [.cancel(closeTitle), .default(confirmTitle)], textFields: [{$0.text = defaultValue}])
            .filter { $0.0 == 1 }
            .map { $0.1[0] }
    }
}
