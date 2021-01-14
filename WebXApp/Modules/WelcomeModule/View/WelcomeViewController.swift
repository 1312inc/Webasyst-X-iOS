//
//  WelcomeViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import UIKit
import RxSwift

protocol WelcomeViewProtocol: class {
    
}

class WelcomeViewController: UIViewController, WelcomeViewProtocol {
    
    //MARK: Data variables
    var viewModel: WelcomeViewModelProtocol!
    var disposeBag = DisposeBag()
    
    //MARK: Interface elements variable
    private var logoImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "TextLogo"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private var welcomeImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "BigLogo"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Webasyst X"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var descriptionAppLabel: UILabel = {
        let label = UILabel()
        label.text = "Our amazing app makes your Webasyst shine at its best and enables you to do things you've never done ever before."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var authButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login with Webasyst Id".uppercased(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemIndigo
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(tapLogin), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var registrationLabel: UILabel = {
        let label = UILabel()
        label.text = "New to Webasyst? Try it free."
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var registrationButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register Now".uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(UIColor.systemIndigo, for: .normal)
        button.addTarget(self, action: #selector(tapRegister), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.setupLayout()
    }
    
    // Hide navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // Show navigation bar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: Setup layout
    private func setupLayout() {
        view.addSubview(logoImage)
        view.addSubview(welcomeImage)
        view.addSubview(appNameLabel)
        view.addSubview(descriptionAppLabel)
        view.addSubview(authButton)
        view.addSubview(registrationLabel)
        view.addSubview(registrationButton)
        NSLayoutConstraint.activate([
            //Top screen constraint
            logoImage.widthAnchor.constraint(equalToConstant: view.frame.width / 3),
            logoImage.heightAnchor.constraint(equalToConstant: 50),
            logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeImage.widthAnchor.constraint(equalToConstant: view.frame.width / 1.5),
            welcomeImage.heightAnchor.constraint(equalToConstant: view.frame.width / 1.5),
            welcomeImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeImage.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 10),
            appNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            appNameLabel.topAnchor.constraint(equalTo: welcomeImage.bottomAnchor, constant: 20),
            descriptionAppLabel.widthAnchor.constraint(equalToConstant: 340),
            descriptionAppLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionAppLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 10),
            //Bottom Screen constraint
            registrationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            registrationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            registrationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            registrationButton.heightAnchor.constraint(equalToConstant: 44),
            registrationLabel.bottomAnchor.constraint(equalTo: registrationButton.topAnchor, constant: -10),
            registrationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            registrationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            authButton.widthAnchor.constraint(equalToConstant: view.frame.width / 1.5),
            authButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authButton.bottomAnchor.constraint(equalTo: registrationLabel.topAnchor, constant: -40),
            authButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    //MARK: User event
    @objc func tapLogin() {
        self.viewModel.tappedLoginButton()
    }
    
    @objc func tapRegister() {
        self.viewModel.tappedRegisterButton()
    }
    
}
