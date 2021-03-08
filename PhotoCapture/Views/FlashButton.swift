//
//  FlashButton.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/7/21.
//

import UIKit
import AVFoundation

@IBDesignable
class FlashButton: BlurButton {
    
    var mode: AVCaptureDevice.FlashMode {
        get {
            return self.flashMode
        }
        set {
            self.set(flash: newValue)
        }
    }
    
    private var flashMode: AVCaptureDevice.FlashMode = .auto

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
        self.mode = .auto
        self.style = .systemUltraThinMaterialLight
        self.button.addTarget(self, action: #selector(self.toggle), for: .touchUpInside)
    }
    
    private func set(flash to: AVCaptureDevice.FlashMode) {
        self.flashMode = to
        
        switch to {
        case .auto:
            self.tint = .black
            self.hideBlurView = true
            self.backgroundColor = .systemYellow
            self.image = UIImage(systemName: "bolt.badge.a.fill")
        case .on:
            self.tint = .white
            self.hideBlurView = false
            self.backgroundColor = .clear
            self.image = UIImage(systemName: "bolt.fill")
        default:
            self.tint = .white
            self.hideBlurView = false
            self.backgroundColor = .clear
            self.image = UIImage(systemName: "bolt.slash.fill")
            break
        }
        
    }
    
    @objc private func toggle() {
        self.mode = AVCaptureDevice.FlashMode(rawValue: (self.mode.rawValue + 1) % 3) ?? .auto
    }
}
