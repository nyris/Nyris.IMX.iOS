//
//  UIViewControllerExtension.swift
//  BarcodeScanner
//
//  Created by MOSTEFAOUIM on 17/06/2023.
//
import Foundation
import UIKit

extension UIViewController {
    /// generic alert view
    func showError(title:String = "Error", message:String, okActionLogic:((UIAlertAction?) -> Void)? = nil) {
        
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action) in
                okActionLogic?(action)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
