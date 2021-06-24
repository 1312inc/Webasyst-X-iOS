//
//  AuthSlide.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 16.06.2021.
//

import UIKit

protocol AuthViewDelegate {
    func openGithub()
    func phoneLogin()
    func webasystIDLogin()
}

class AuthSlide: UIView {

    private var textLogoImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "TextLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var biglogoImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BigLogo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var appNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var gitHubButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(openGithubTap), for: .touchDown)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var loginPhoneNumberButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(phoneLoginTap), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var orLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var loginWebasystButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.setTitleColor(UIColor.label, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.systemGray3.cgColor
        button.layer.borderWidth = 1
        let icon = UIImage(named: "magic-wand-small")!
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(loginWebasystIDTap), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var delegate: AuthViewDelegate!
    
    override func didMoveToSuperview() {
        appNameLabel.text = NSLocalizedString("appName", comment: "")
        descriptionLabel.text = NSLocalizedString("appDescription", comment: "")
        gitHubButton.setTitle(NSLocalizedString("onGithub", comment: ""), for: .normal)
        loginPhoneNumberButton.setTitle(NSLocalizedString("phoneLogin", comment: ""), for: .normal)
        orLabel.text = NSLocalizedString("orLabel", comment: "")
        loginWebasystButton.setTitle(NSLocalizedString("loginButtonTitle", comment: ""), for: .normal)
        self.setupuLayout()
    }
    
    private func setupuLayout() {
        self.addSubview(textLogoImage)
        self.addSubview(biglogoImage)
        self.addSubview(appNameLabel)
        self.addSubview(descriptionLabel)
        self.addSubview(gitHubButton)
        self.addSubview(loginPhoneNumberButton)
        self.addSubview(orLabel)
        self.addSubview(loginWebasystButton)
        NSLayoutConstraint.activate([
            textLogoImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textLogoImage.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20),
            textLogoImage.heightAnchor.constraint(equalToConstant: 30),
            textLogoImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            biglogoImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            biglogoImage.widthAnchor.constraint(equalToConstant: 150),
            biglogoImage.heightAnchor.constraint(equalToConstant: 150),
            biglogoImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -(self.superview?.frame.height ?? 0) / 6),
            appNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            appNameLabel.widthAnchor.constraint(equalToConstant: self.superview?.frame.width ?? 0),
            appNameLabel.topAnchor.constraint(equalTo: self.biglogoImage.bottomAnchor, constant: 10),
            descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
            descriptionLabel.topAnchor.constraint(equalTo: self.appNameLabel.bottomAnchor, constant: 10),
            gitHubButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            gitHubButton.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
            gitHubButton.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 10),
            loginPhoneNumberButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loginPhoneNumberButton.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
            loginPhoneNumberButton.heightAnchor.constraint(equalToConstant: 50),
            loginPhoneNumberButton.bottomAnchor.constraint(equalTo: self.orLabel.topAnchor, constant: -10),
            orLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            orLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
            orLabel.bottomAnchor.constraint(equalTo: self.loginWebasystButton.topAnchor, constant: -10),
            loginWebasystButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loginWebasystButton.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -40),
            loginWebasystButton.heightAnchor.constraint(equalToConstant: 50),
            loginWebasystButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
        ])
    }

    @objc func openGithubTap() {
        self.delegate.openGithub()
    }
    
    @objc func phoneLoginTap() {
        self.delegate.phoneLogin()
    }
    
    @objc func loginWebasystIDTap() {
        self.delegate.webasystIDLogin()
    }
    
}
