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

    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var gitHubButton: UIButton!
    @IBOutlet weak var loginPhoneNumberButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var loginWebasystButton: UIButton!
    
    var delegate: AuthViewDelegate!
    
    override func didMoveToSuperview() {
        appNameLabel.text = NSLocalizedString("appName", comment: "")
        descriptionLabel.text = NSLocalizedString("appDescription", comment: "")
        gitHubButton.setTitle(NSLocalizedString("onGithub", comment: ""), for: .normal)
        loginPhoneNumberButton.setTitle(NSLocalizedString("phoneLogin", comment: ""), for: .normal)
        orLabel.text = NSLocalizedString("orLabel", comment: "")
        loginWebasystButton.setTitle(NSLocalizedString("loginButtonTitle", comment: ""), for: .normal)
        loginWebasystButton.layer.cornerRadius = 10
        loginWebasystButton.layer.borderColor = UIColor.black.cgColor
        loginWebasystButton.layer.borderWidth = 1
        loginPhoneNumberButton.layer.cornerRadius = 10
    }

    @IBAction func openGithubTap(_ sender: Any) {
        self.delegate.openGithub()
    }
    
    @IBAction func phoneLoginTap(_ sender: Any) {
        self.delegate.phoneLogin()
    }
    
    @IBAction func loginWebasystIDTap(_ sender: Any) {
        self.delegate.webasystIDLogin()
    }
    
}
