//
//  InstallModuleView.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 16.06.2021.
//

import UIKit

protocol InstallModuleViewDelegate {
    func installModuleTap()
}

class InstallModuleView: UIView {

    var delegate: InstallModuleViewDelegate!
    var moduleName: String!
    var installName: String!
    
    private var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "installImage")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var installModuleLabel: UILabel = {
        let label = UILabel()
        let localizedString = NSLocalizedString("installModule", comment: "")
        let replacedString = String(format: localizedString, moduleName, installName)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = replacedString
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        let localizedString = NSLocalizedString("installDescription", comment: "")
        let replacedString = String(format: localizedString, moduleName)
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.systemGray2
        label.text = replacedString
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var installModuleButton: UIButton = {
        var button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.systemGray6
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.setTitle(NSLocalizedString("installButton", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(installModuleButtonTap), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func layoutSubviews() {
        self.addSubview(icon)
        self.addSubview(installModuleLabel)
        self.addSubview(installModuleButton)
        self.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            installModuleLabel.widthAnchor.constraint(equalToConstant: self.frame.width - 20),
            installModuleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            installModuleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            icon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 80),
            icon.heightAnchor.constraint(equalToConstant: 80),
            icon.bottomAnchor.constraint(equalTo: installModuleLabel.topAnchor, constant: -20),
            descriptionLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
            descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: self.installModuleLabel.bottomAnchor, constant: 10),
            installModuleButton.widthAnchor.constraint(equalToConstant: self.frame.width - 40),
            installModuleButton.heightAnchor.constraint(equalToConstant: 44),
            installModuleButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            installModuleButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
    }
    
    @objc private func installModuleButtonTap() {
        self.delegate.installModuleTap()
    }

}
