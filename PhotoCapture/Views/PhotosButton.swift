//
//  PhotosButton.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/8/21.
//

import UIKit

protocol PhotosDelegate {
    func photosButtonPressed()
}

@IBDesignable
class PhotosButton: BlurButton {
    
    var delegate: PhotosDelegate?

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
        self.cornerRadius = self.frame.height / 2
        self.style = .systemUltraThinMaterialLight
        self.image = UIImage(systemName: "photo.on.rectangle.angled")
        self.button.addTarget(self, action: #selector(self.pressed), for: .touchUpInside)
    }
    
    @objc private func pressed() {
        self.delegate?.photosButtonPressed()
    }
    
}
