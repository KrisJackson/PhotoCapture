//
//  RoundedView.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/3/21.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
}

@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
}

@IBDesignable
class RoundedImageView: UIImageView {

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
}
