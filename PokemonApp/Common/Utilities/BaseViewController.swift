//
//  BaseViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    internal let disposeBag = DisposeBag()
    
    internal func displayAlert(
        title: String,
        message: String,
        actionTitle: String = "OK",
        actionStyle: UIAlertAction.Style = .default,
        showSecondAction: Bool = false,
        secondActionTitle: String = "Cancel",
        secondActionStyle: UIAlertAction.Style = .cancel,
        actionHandler: ((UIAlertAction) -> Void)? = nil,
        secondActionHandler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: actionHandler)
        alertController.addAction(action)
        if showSecondAction {
            let secondAction = UIAlertAction(title: secondActionTitle, style: secondActionStyle, handler: secondActionHandler)
            alertController.addAction(secondAction)
        }
        present(alertController, animated: true, completion: nil)
    }
}
