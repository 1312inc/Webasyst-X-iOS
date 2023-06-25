//
//  EmailConfirmationAppleIDViewController.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 13.03.2023.
//

import UIKit
import Webasyst

protocol EmailConfirmationDelegate {
    var alertPresenter: UIViewController { get }
    func startLoading()
    func stopLoading()
}

class EmailConfirmationAppleIDViewController: UIViewController, UIDeviceShared, EmailConfirmationDelegate {

    lazy var alertPresenter: UIViewController = self
    
    let email: String?
    let completion: (AuthAppleIDResult.EmailConfirmation.Result, EmailConfirmationDelegate) -> ()
    
    init(email: String?, completion: @escaping (AuthAppleIDResult.EmailConfirmation.Result, EmailConfirmationDelegate) -> ()) {
        self.email = email
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .adaptiveFont(.largeTitle, 22)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = .getLocalizedString(withKey: "titleConfirmCode")
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        
        label.font = .adaptiveFont(.body, 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let codeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .systemGray6
        stackView.layer.cornerRadius = 56 / 4
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    public let topLayerOfCodeStackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        
        let text: String = .getLocalizedString(withKey: "appleLoginEmailConfirmationLogout")
        button.setTitle(text, for: .normal)
        
        button.titleLabel?.font = .adaptiveFont(.body, 16, .semibold)
        button.setTitleColor(.appColor, for: .normal)
        button.setTitleColor(.appColor.withAlphaComponent(0.5), for: .highlighted)
        
        button.layer.cornerRadius = 10
        button.layer.borderColor = isDark ? UIColor.systemGray6.cgColor : UIColor.systemGray5.cgColor
        button.layer.borderWidth = 2
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createNavigation()
        configure()
        setupLayouts()
    }
    
    private func createNavigation() {
        view.backgroundColor = .reverseLabel
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configure() {
        
        var description: String
        if let email = email {
            description = .getLocalizedString(withKey: "appleLoginEmailConfirmationDescription").replacingOccurrences(of: "%email%", with: " \(email)")
        } else {
            description = .getLocalizedString(withKey: "appleLoginEmailConfirmationDescription").replacingOccurrences(of: "%email%", with: "")
        }
        let attributedString = NSMutableAttributedString(string: description)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .center
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        descriptionLabel.attributedText = attributedString
        
        for _ in 0..<2 {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            stackView.isLayoutMarginsRelativeArrangement = true
            for _ in 0..<4 {
                let textField = UITextField()
                textField.font = .adaptiveFont(.body, 22, .bold)
                textField.tintColor = .appColor
                textField.placeholder = "•"
                textField.keyboardType = .numberPad
                textField.delegate = self
                stackView.addArrangedSubview(textField)
            }
            codeStackView.addArrangedSubview(stackView)
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gesture)
        
        let codeStackGesture = UITapGestureRecognizer(target: self, action: #selector(codeStackViewPressed))
        topLayerOfCodeStackView.addGestureRecognizer(codeStackGesture)
        
        let logoutGesture = UITapGestureRecognizer(target: self, action: #selector(logout))
        logoutButton.addGestureRecognizer(logoutGesture)
    }

    private func setupLayouts() {
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(codeStackView)
        view.addSubview(loadingView)
        view.addSubview(topLayerOfCodeStackView)
        view.addSubview(logoutButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(4)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().inset(32)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().inset(32)
        }
        
        let width = "4".width(by: .adaptiveFont(.body, 22, .bold)) * 8 + 6 * 8 + 48
        codeStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(56)
            make.width.equalTo(width)
        }
        
        loadingView.snp.makeConstraints { make in
            make.centerY.equalTo(codeStackView.snp.centerY)
            make.leading.equalTo(codeStackView.snp.trailing).offset(16)
        }
        
        topLayerOfCodeStackView.snp.makeConstraints { make in
            make.edges.equalTo(codeStackView)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(codeStackView).inset(32)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(32).priority(.low)
            make.height.equalTo(50)
        }
    }
}

extension EmailConfirmationAppleIDViewController {
    
    func startLoading() {
        logoutButton.isUserInteractionEnabled = false
        codeStackView.isUserInteractionEnabled = false
        topLayerOfCodeStackView.isUserInteractionEnabled = false
        loadingView.startAnimating()
    }
    
    func stopLoading() {
        logoutButton.isUserInteractionEnabled = true
        codeStackView.isUserInteractionEnabled = true
        topLayerOfCodeStackView.isUserInteractionEnabled = true
        loadingView.stopAnimating()
    }
}

@objc
extension EmailConfirmationAppleIDViewController {
    
    private func send(code: String) {
        startLoading()
        completion(.code(code), self)
    }
    
    private func logout() {
        startLoading()
        completion(.logout, self)
    }
    
    private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    private func codeStackViewPressed() {
        
        var lastTF: UITextField? = codeStackView.subviews.first?.subviews.first as? UITextField
        for stackView in codeStackView.subviews {
            for tf in stackView.subviews {
                if let tf = tf as? UITextField {
                    if tf.text == nil || tf.text?.isEmpty ?? true {
                        lastTF?.becomeFirstResponder()
                        return
                    }
                    lastTF = tf
                }
            }
        }
        
        (codeStackView.subviews.last?.subviews.last as? UITextField)?.becomeFirstResponder()
    }
}

extension EmailConfirmationAppleIDViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string != "" {
            
            var code: String = ""
            
            for (i, stackView) in codeStackView.subviews.enumerated() {
                for (j, tf) in stackView.subviews.enumerated() {
                    if let tf = tf as? UITextField {
                        
                        code += tf.text ?? ""
                        
                        if tf.text == nil || tf.text?.isEmpty ?? true {
                            
                            tf.text = string
                            tf.becomeFirstResponder()
                            if i == 1 && j == 3 {
                                
                                code += tf.text ?? ""
                                
                                send(code: code)
                                
                                self.view.endEditing(true)
                            }
                            
                            return false
                        }
                    }
                }
            }
        } else {
            var lastTF: UITextField? = codeStackView.subviews.first?.subviews.first as? UITextField
            for stackView in codeStackView.subviews {
                for tf in stackView.subviews {
                    if let tf = tf as? UITextField {
                        if tf === textField {
                            tf.text = string
                            lastTF?.becomeFirstResponder()
                            return false
                        }
                        lastTF = tf
                    }
                }
            }
        }
            
        return false
    }
}

// MARK: - Light / Dark mode

extension EmailConfirmationAppleIDViewController {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .light:
            logoutButton.layer.borderColor = UIColor.systemGray5.cgColor
        case .dark, .unspecified:
            logoutButton.layer.borderColor = UIColor.systemGray6.cgColor
        @unknown default:
            break
        }
    }
}
