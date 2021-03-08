//
//  CameraPrivacyView.swift
//  PhotoCapture
//
//  Created by Kristopher Jackson on 2/8/21.
//

import UIKit

@IBDesignable
class CameraPrivacyView: RoundedView {
    
    private var headerLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 20, weight: .black)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = NSLocalizedString("CAMERA_DISABLED_HEADER", comment: "Header")
        return view
    }()
    
    private var textLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 8
        view.textColor = .black
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = NSLocalizedString("CAMERA_DISABLED_TEXT", comment: "General")
        return view
    }()
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .system)
        view.setTitleColor(.systemBlue, for: .normal)
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        view.addTarget(self, action: #selector(self.goToSettings), for: .touchUpInside)
        view.setTitle(NSLocalizedString("GO_TO_SETTING_BUTTON", comment: "Button"), for: .normal)
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
        self.cornerRadius = 10
        self.clipsToBounds = true
        self.backgroundColor = .white
        
        self.addSubview(self.headerLabel)
        NSLayoutConstraint.activate([
            self.headerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.headerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            self.headerLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
        ])
        
        self.addSubview(self.textLabel)
        NSLayoutConstraint.activate([
            self.textLabel.widthAnchor.constraint(equalTo: self.headerLabel.widthAnchor),
            self.textLabel.centerXAnchor.constraint(equalTo: self.headerLabel.centerXAnchor),
            self.textLabel.topAnchor.constraint(equalTo: self.headerLabel.bottomAnchor, constant: 8),
        ])
        
        self.addSubview(self.button)
        NSLayoutConstraint.activate([
            self.button.heightAnchor.constraint(equalToConstant: 60),
            self.button.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.button.topAnchor.constraint(equalTo: self.textLabel.bottomAnchor, constant: 20),
        ])
    }
    
    /// Navigate user to Settings to enable camera privacy settings
    @objc private func goToSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}
