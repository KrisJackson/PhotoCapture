//
//  ContinueButton.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/9/21.
//

import UIKit

protocol ContinueButtonDelegate {
    func continuePressed()
}

@IBDesignable
class ContinueButton: BlurView {
    
    var delegate: ContinueButtonDelegate?
    
    private var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16, weight: .bold)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = NSLocalizedString("CONTINUE_BUTTON", comment: "Button")
        return view
    }()
    
    private var iconImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "chevron.right"))
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.preferredSymbolConfiguration = .init(font: .systemFont(ofSize: 16, weight: .bold))
        return view
    }()
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(self.continuePressed), for: .touchUpInside)
        view.addTarget(self, action: #selector(self.touchDown), for: .touchDown)
        view.addTarget(self, action: #selector(self.touchDown), for: .touchDragEnter)
        view.addTarget(self, action: #selector(self.touchRelease), for: .touchUpInside)
        view.addTarget(self, action: #selector(self.touchRelease), for: .touchDragExit)
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
    
    required init(style: UIBlurEffect.Style = .dark) {
        fatalError("init(style:) has not been implemented")
    }
    
    private func configure() {
        
        self.style = .systemUltraThinMaterialLight
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height / 2
        
        self.addSubview(self.titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15),
        ])
        
        self.addSubview(self.iconImage)
        NSLayoutConstraint.activate([
            self.iconImage.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.iconImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15),
            self.iconImage.leftAnchor.constraint(equalTo: self.titleLabel.rightAnchor, constant: 5),
        ])
        
        self.addSubview(self.button)
        NSLayoutConstraint.activate([
            self.button.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.button.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    @objc private func continuePressed() {
        self.delegate?.continuePressed()
    }
    
    @objc private func touchDown() {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.iconImage.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
            self.titleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
            self.layoutIfNeeded()
        }
    }
    
    @objc private func touchRelease() {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.iconImage.tintColor = .white
            self.titleLabel.textColor = .white
            self.layoutIfNeeded()
        }
    }
}
