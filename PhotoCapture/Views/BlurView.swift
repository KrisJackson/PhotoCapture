//
//  BlurView.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/3/21.
//

import UIKit

class BlurView: UIView {
    
    var style: UIBlurEffect.Style {
        get {
            return self.effectStyle
        }
        set {
            self.effectStyle = newValue
            self.blurView.removeFromSuperview()
            self.createBlurView(withStyle: newValue)
            self.addSubview(self.blurView)
        }
    }
    
    private var blurView: UIVisualEffectView!
    private var effectStyle: UIBlurEffect.Style!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setUp(withStyle: .dark)
    }
    
    required init(style: UIBlurEffect.Style = .dark) {
        super.init(frame: .zero)
        self.setUp(withStyle: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp(withStyle: .dark)
    }
    
    private func setUp(withStyle style: UIBlurEffect.Style) {
        self.effectStyle = style
        self.backgroundColor = .clear
        self.createBlurView(withStyle: style)
        self.addSubview(self.blurView)
    }
    
    private func createBlurView(withStyle style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        let view = UIVisualEffectView(effect: blurEffect)
        view.frame.origin = .zero
        view.frame.size = self.frame.size
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurView = view
    }

}

@IBDesignable
class DarkBlurImageView: UIImageView {
    
    private lazy var darkBlurView: BlurView = {
        let view = BlurView()
        view.frame.origin = .zero
        view.frame.size = self.frame.size
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.addSubview(self.darkBlurView)
    }
    
    required init() {
        super.init(frame: .zero)
        self.addSubview(self.darkBlurView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(self.darkBlurView)
    }

}

@IBDesignable
class BlurButton: UIView {
    
    var hideBlurView: Bool {
        get {
            return self.blurView.isHidden
        }
        set {
            self.blurView.isHidden = newValue
        }
    }
    
    var style: UIBlurEffect.Style {
        get {
            return self.blurView.style
        }
        set {
            self.blurView.style = newValue
        }
    }
    
    @IBInspectable
    var tint: UIColor? {
        get {
            return self.button.tintColor
        }
        set {
            self.button.tintColor = newValue
        }
    }
    
    @IBInspectable
    var image: UIImage? {
        get {
            return self.button.imageView?.image
        }
        set {
            self.button.setImage(newValue, for: .normal)
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.masksToBounds = true
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    lazy var button: UIButton = {
        let view = UIButton()
        view.frame.origin = .zero
        view.frame.size = self.frame.size
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    private lazy var blurView: BlurView = {
        let view = BlurView()
        view.frame.origin = .zero
        view.frame.size = self.frame.size
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.configure()
    }
    
    required init() {
        super.init(frame: .zero)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }

    private func configure() {
        self.addSubview(self.blurView)
        self.sendSubviewToBack(self.blurView)
        self.addSubview(self.button)
        self.backgroundColor = .clear
    }
    
}
