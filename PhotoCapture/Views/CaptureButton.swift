//
//  CaptureButton.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/7/21.
//

import UIKit
import AVFoundation

protocol CaptureDelegate {
    func captureIsPressed()
}

@IBDesignable
class CaptureButton: BlurButton {
    
    var delegate: CaptureDelegate?

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
        self.layer.borderWidth = 5
        self.style = .systemUltraThinMaterialLight
        self.layer.borderColor = UIColor.white.cgColor
        self.button.addTarget(self, action: #selector(self.capture), for: .touchUpInside)
        
        self.button.addTarget(self, action: #selector(self.touchDown), for: .touchDown)
        self.button.addTarget(self, action: #selector(self.touchDown), for: .touchDragEnter)
        self.button.addTarget(self, action: #selector(self.touchRelease), for: .touchUpInside)
        self.button.addTarget(self, action: #selector(self.touchRelease), for: .touchDragExit)
    }
    
    @objc private func capture() {
        self.delegate?.captureIsPressed()
    }
    
    @objc private func touchDown() {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
            self.layoutIfNeeded()
        }
    }
    
    @objc private func touchRelease() {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.borderColor = .white
            self.layoutIfNeeded()
        }
    }
}
