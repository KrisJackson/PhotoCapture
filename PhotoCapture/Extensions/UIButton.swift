//
//  UIButton.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 3/8/21.
//

import UIKit

extension UIButton {
    
    func lock() {
        self.isEnabled = false
    }
    
    func unlock() {
        self.isEnabled = true
    }
    
}
