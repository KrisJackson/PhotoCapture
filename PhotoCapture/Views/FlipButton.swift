//
//  FlipButton.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/7/21.
//

import UIKit
import AVFoundation

protocol FlipDelegate {
    func flipButtonPressed()
}

@IBDesignable
class FlipButton: BlurButton {
    
    var delegate: FlipDelegate?

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
        self.tint = .white
        self.style = .systemUltraThinMaterialLight
        self.image = UIImage(systemName: "arrow.triangle.2.circlepath")
        self.button.addTarget(self, action: #selector(self.toggle), for: .touchUpInside)
    }
    
    @objc private func toggle() {
        self.delegate?.flipButtonPressed()
    }
}
