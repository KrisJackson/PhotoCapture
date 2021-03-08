//
//  PhotoPreviewViewController.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/9/21.
//

import UIKit

protocol PhotoPreviewDelegate {
    func preview(_ preview: PhotoPreviewViewController, didUse image: UIImage)
}

class PhotoPreviewViewController: UIViewController {
    
    static let storyboardID = "PhotoPreviewViewController"
    
    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            DispatchQueue.main.async {
                self.imageView.image = newValue
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dismiss: RoundedButton!
    @IBOutlet weak var continueButton: RoundedButton!
    
    var delegate: PhotoPreviewDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.leavePreview()
    }
    
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.continueButton.lock()
        if let image = self.imageView.image {
            self.delegate?.preview(self, didUse: image)
        }
        self.leavePreview()
        self.continueButton.unlock()
    }
    
    private func leavePreview() {
        self.genericDismiss()
    }
}
