//
//  UIViewController.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 3/8/21.
//

import UIKit

extension UIViewController {
    
    func genericDismiss() {
        guard let navigationController = self.navigationController else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if navigationController.viewControllers.count == 1 {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
    
}
