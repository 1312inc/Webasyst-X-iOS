//
//  AuthSlide.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 03.10.2022.
//

import UIKit
import libPhoneNumber_iOS
import DropDown

protocol AuthViewDelegate: AnyObject {
    func openDemoViewController()
    func phoneLogin()
    func appleIDLogin()
    func webasystIDLogin()
    func QRLogin()
    func select(name: String)
}

class AuthSlide: UIView, UIDeviceShared {
    
    private var layoutConstant: CGFloat {
        let condition = UIDevice.modelName.contains("SE")
        if condition || isSmall {
            return -10
        } else if isMedium && !condition {
            return -20
        } else {
            return -40
        }
    }

    private var countryName = ""
    private var layoutSubviewsIsSet = false
    
    private lazy var webasystLogo: UIImageView = {
        let image = UIImage(named: "WebasystIDLogo")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var webasystLogoLabel: UILabel = {
        let label = UILabel()
        label.font = .adaptiveFont(.largeTitle, 30, .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dropDownListButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .trailing
        button.semanticContentAttribute = .forceRightToLeft
        
        let image = UIImage(systemName: "chevron.down")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        let highlightedimage = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(highlightedimage, for: .highlighted)
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.tintColor = .systemGray2
        button.imageView?.contentMode = .scaleAspectFit

        button.titleLabel?.font = .adaptiveFont(.headline, 17, .semibold)
        button.tintColor = .label
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.systemGray2, for: .highlighted)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        return button
    }()

    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .adaptiveFont(.subheadline, 15)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var viewDemoAccount: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(openDemoViewController), for: .touchUpInside)
        button.setTitleColor(.appColor, for: .normal)
        button.setTitleColor(.appColor.withAlphaComponent(0.5), for: .highlighted)
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.backgroundColor = .appColor.withAlphaComponent(0.1)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var dropDownList: DropDown = {
        let dropDown = DropDown()
        dropDown.direction = .bottom
        dropDown.backgroundColor = isDark ? .systemGray6 : .systemGray5
        dropDown.textColor = .label
        return dropDown
    }()

    private lazy var loginPhoneNumberButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        button.backgroundColor = isDark ? .systemGray6 : .systemGray5
        if isDark {
            button.titleLabel?.layer.opacity = 0.4
        }
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(phoneLoginTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()

    var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.backgroundColor = .reverseLabel
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numberPad
        if let localCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String,
           let countryCode = NBPhoneNumberUtil.sharedInstance().getCountryCode(forRegion: localCode) {
            textField.text = "+\(countryCode)"
        }
        textField.tintColor = .appColor
        return textField
    }()

    private lazy var aboutWebAsyst: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.appColor, for: .normal)
        button.setTitleColor(.appColor.withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(open), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginAppleIDButton: UIButton = {
        let button = UIButton()
        
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.systemGray2, for: .highlighted)
        button.tintColor = .label
        
        button.layer.cornerRadius = 10
        button.layer.borderColor = isDark ? UIColor.systemGray6.cgColor : UIColor.systemGray5.cgColor
        button.layer.borderWidth = 2
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        let icon = (UIImage(systemName: "apple.logo") ?? UIImage(systemName: "applelogo"))?.withTintColor(.label, renderingMode: .alwaysOriginal)
        let highlightedIcon = (UIImage(systemName: "apple.logo") ?? UIImage(systemName: "applelogo"))?.withRenderingMode(.alwaysTemplate)
        button.setImage(icon, for: .normal)
        button.setImage(highlightedIcon, for: .highlighted)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = .systemGray2
        
        button.addTarget(self, action: #selector(loginAppleIDTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    private lazy var loginWebasystButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.systemGray2, for: .highlighted)
        button.layer.cornerRadius = 10
        button.layer.borderColor = isDark ? UIColor.systemGray6.cgColor : UIColor.systemGray5.cgColor
        button.layer.borderWidth = 2
        button.addTarget(self, action: #selector(loginWebasystIDTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loginQRButton: UIButton = {
        let button = UIButton()
        
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.systemGray2, for: .highlighted)
        button.tintColor = .label
        
        button.layer.cornerRadius = 10
        button.layer.borderColor = isDark ? UIColor.systemGray6.cgColor : UIColor.systemGray5.cgColor
        button.layer.borderWidth = 2
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        
        let icon = UIImage(systemName: "qrcode.viewfinder")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        let highlightedIcon = UIImage(systemName: "qrcode.viewfinder")!.withRenderingMode(.alwaysTemplate)
        button.setImage(icon, for: .normal)
        button.setImage(highlightedIcon, for: .highlighted)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = .systemGray2
        
        button.addTarget(self, action: #selector(loginQRTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let overlayView: UIView = {
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isHidden = true
        overlayView.alpha = 0
        overlayView.backgroundColor = .reverseLabel.withAlphaComponent(0.8)
        return overlayView
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.backgroundColor = .reverseLabel
        loadingView.layer.borderColor = isDark ? UIColor.systemGray4.cgColor : UIColor.systemGray2.cgColor
        loadingView.layer.borderWidth = 3
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.alpha = 0
        loadingView.isHidden = true
        return loadingView
    }()
    
    func startLoading() {
            self.overlayView.isHidden = false
            self.loadingView.isHidden = false
            self.loadingView.startAnimating()
            UIView.animate(withDuration: 0.3) {
                self.loadingView.alpha = 1
                self.overlayView.alpha = 1
            }
    }
    
    func stopLoading() {
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 0
            self.loadingView.alpha = 0
        } completion: { _ in
            self.loadingView.stopAnimating()
            self.overlayView.isHidden = true
            self.loadingView.isHidden = true
        }
    }
    
    fileprivate let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    fileprivate let contentView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    weak var delegate: AuthViewDelegate?
    var type: AuthCoordinator.AuthType!

    override func didMoveToSuperview() {
        
        backgroundColor = .systemBackground
        
        aboutWebAsyst.setTitle(.getLocalizedString(withKey: "aboutWebAsystID"), for: .normal)
        dropDownListButton.setTitle(countryName, for: .normal)
        
        switch type {
        case .express(let domain, _):
            
            if let domain = domain {
                webasystLogoLabel.text = domain
            }
            loginPhoneNumberButton.setTitle(.getLocalizedString(withKey: "expressPhoneLogin"), for: .normal)
            
            let attributedString = NSMutableAttributedString(string: .getLocalizedString(withKey: "phoneDescription"))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.alignment = .center
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            descriptionLabel.attributedText = attributedString
            
        case .normal, .none:
            
            loginPhoneNumberButton.setTitle(.getLocalizedString(withKey: "phoneLogin"), for: .normal)
            loginAppleIDButton.setTitle(.getLocalizedString(withKey: "appleLogin"), for: .normal)
            loginWebasystButton.setTitle(.getLocalizedString(withKey: "emailLogin"), for: .normal)
            loginQRButton.setTitle(.getLocalizedString(withKey: "QRLogin"), for: .normal)
            viewDemoAccount.setTitle(.getLocalizedString(withKey: "viewDemoAccount"), for: .normal)
            
            let attributedString = NSMutableAttributedString(string: .getLocalizedString(withKey: "appDescription"))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.alignment = .center
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            descriptionLabel.attributedText = attributedString

        }
        
        setupLayout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let current = Locale(identifier: Locale.current.identifier)
        if let countryCode = Locale.current.regionCode,
           let countryName = current.localizedString(forRegionCode: countryCode) {
            self.countryName = countryName
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        if !layoutSubviewsIsSet {
            layoutSubviewsIsSet = true
        } else {
            layoutIfNeeded()
            return
        }
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        addSubview(overlayView)
        addSubview(loadingView)
        contentView.addSubview(dropDownListButton)
        contentView.addSubview(dropDownList)
        contentView.addSubview(textField)
        contentView.addSubview(loginPhoneNumberButton)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(aboutWebAsyst)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            loadingView.widthAnchor.constraint(equalTo: loadingView.heightAnchor, multiplier: 1/1),
            loadingView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            dropDownListButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dropDownListButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
            dropDownListButton.heightAnchor.constraint(equalToConstant: 50),
            dropDownListButton.imageView!.centerYAnchor.constraint(equalTo: dropDownListButton.centerYAnchor),
            dropDownListButton.imageView!.leadingAnchor.constraint(equalTo: dropDownListButton.leadingAnchor, constant: 10),
            textField.topAnchor.constraint(equalTo: dropDownListButton.bottomAnchor, constant: 10),
            textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
            textField.heightAnchor.constraint(equalToConstant: 55),
            loginPhoneNumberButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            loginPhoneNumberButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginPhoneNumberButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
            loginPhoneNumberButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        switch type {
        case .express(let domain, _):
            
            if domain != nil {
                contentView.addSubview(webasystLogoLabel)
                NSLayoutConstraint.activate([
                    webasystLogoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                    webasystLogoLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
                    webasystLogoLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
                    descriptionLabel.topAnchor.constraint(equalTo: webasystLogoLabel.bottomAnchor, constant: 16)
                ])
            } else {
                contentView.addSubview(webasystLogo)
                NSLayoutConstraint.activate([
                    webasystLogo.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                    webasystLogo.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
                    webasystLogo.heightAnchor.constraint(equalToConstant: 32),
                    descriptionLabel.topAnchor.constraint(equalTo: webasystLogo.bottomAnchor, constant: 16)
                ])
            }
            
            NSLayoutConstraint.activate([
                descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                descriptionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
                dropDownListButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
                aboutWebAsyst.topAnchor.constraint(equalTo: loginPhoneNumberButton.bottomAnchor, constant: 8),
                aboutWebAsyst.heightAnchor.constraint(equalToConstant: 50),
                aboutWebAsyst.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            ])
            
        case .normal, .none:
            
            contentView.addSubview(webasystLogo)
            contentView.addSubview(viewDemoAccount)
            contentView.addSubview(loginAppleIDButton)
            contentView.addSubview(loginWebasystButton)
            contentView.addSubview(loginQRButton)
            
            NSLayoutConstraint.activate([
                webasystLogo.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                webasystLogo.heightAnchor.constraint(equalToConstant: 32),
                webasystLogo.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
                dropDownListButton.topAnchor.constraint(equalTo: webasystLogo.bottomAnchor, constant: 16),
                loginAppleIDButton.topAnchor.constraint(equalTo: loginPhoneNumberButton.bottomAnchor, constant: 42),
                loginAppleIDButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loginAppleIDButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
                loginAppleIDButton.heightAnchor.constraint(equalToConstant: 50),
                loginAppleIDButton.bottomAnchor.constraint(equalTo: loginWebasystButton.topAnchor, constant: -16),
                loginWebasystButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loginWebasystButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
                loginWebasystButton.heightAnchor.constraint(equalToConstant: 50),
                loginWebasystButton.bottomAnchor.constraint(equalTo: loginQRButton.topAnchor, constant: -16),
                loginQRButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                loginQRButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
                loginQRButton.heightAnchor.constraint(equalToConstant: 50),
                descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                descriptionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
                descriptionLabel.topAnchor.constraint(equalTo: loginQRButton.safeAreaLayoutGuide.bottomAnchor, constant: 20),
                aboutWebAsyst.heightAnchor.constraint(equalToConstant: 50),
                aboutWebAsyst.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                aboutWebAsyst.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
                viewDemoAccount.topAnchor.constraint(greaterThanOrEqualTo: aboutWebAsyst.bottomAnchor, constant: 20),
                viewDemoAccount.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                viewDemoAccount.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.85),
                viewDemoAccount.heightAnchor.constraint(equalToConstant: 50),
                viewDemoAccount.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: layoutConstant)
            ])
            
        }
        
        layoutIfNeeded()
        
        loadingView.layer.cornerRadius = loadingView.frame.height / 8
        
        let height = descriptionLabel.getSize(constrainedWidth: frame.width * 0.85)
        descriptionLabel.heightAnchor.constraint(equalToConstant: height.height).isActive = true
        
        extendedLayout()
        hide()
    }

    @objc func openDemoViewController() {
        self.endEditing(true)
        self.delegate?.openDemoViewController()
    }

    @objc func phoneLoginTap() {
        self.endEditing(true)
        self.delegate?.phoneLogin()
    }
    
    @objc func loginAppleIDTap() {
        self.endEditing(true)
        self.delegate?.appleIDLogin()
    }

    @objc func loginWebasystIDTap() {
        self.endEditing(true)
        self.delegate?.webasystIDLogin()
    }
    
    @objc func loginQRTap() {
        self.endEditing(true)
        self.delegate?.QRLogin()
    }

    @objc func click() {
        self.dropDownList.width = dropDownListButton.frame.width
        self.dropDownList.anchorView = dropDownListButton
        self.dropDownList.show()
    }

    private func hide() {
        dropDownList.selectionAction = { [weak self] index, item in
            self?.dropDownListButton.setTitle(item, for: .normal)
            self?.delegate?.select(name: item)
            self?.backgroundColor(canNext: false)
        }
    }

    @objc func open() {
        let url: String = .getLocalizedString(withKey: "webasystURL")
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }

    private func extendedLayout() {
        
        let dropDownLineView = UIView()
        dropDownLineView.translatesAutoresizingMaskIntoConstraints = false
        dropDownLineView.backgroundColor = .gray.withAlphaComponent(0.3)
        
        dropDownListButton.addSubview(dropDownLineView)
        
        NSLayoutConstraint.activate([
            dropDownLineView.leadingAnchor.constraint(equalTo: dropDownListButton.leadingAnchor),
            dropDownLineView.bottomAnchor.constraint(equalTo: dropDownListButton.bottomAnchor),
            dropDownLineView.heightAnchor.constraint(equalToConstant: 1),
            dropDownLineView.widthAnchor.constraint(equalTo: dropDownListButton.widthAnchor)
        ])
        
        let textFieldLineView = UIView()
        textFieldLineView.translatesAutoresizingMaskIntoConstraints = false
        textFieldLineView.backgroundColor = .gray.withAlphaComponent(0.3)
        
        textField.addSubview(textFieldLineView)
        
        NSLayoutConstraint.activate([
            textFieldLineView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            textFieldLineView.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            textFieldLineView.heightAnchor.constraint(equalToConstant: 1),
            textFieldLineView.widthAnchor.constraint(equalTo: textField.widthAnchor)
        ])

    }

    public func setUpDataSource(data: [String]) {
        DropDown.startListeningToKeyboard()
        dropDownList.width = dropDownListButton.frame.width
        dropDownList.dataSource = data
    }

    public func setTitle(_ countryName: String) {
        if dropDownListButton.titleLabel?.text != countryName {
            dropDownListButton.setTitle(countryName, for: .normal)
            self.countryName = countryName
        }
    }

    public func setCode(_ code: Int) {
        textField.text = "+\(code)"
    }

    public func interactiveController(_ bool: Bool) {
        loginPhoneNumberButton.backgroundColor = bool ? .appColor : (isDark ? .systemGray6 : .systemGray5)
        loginPhoneNumberButton.isUserInteractionEnabled = bool
    }

    public func backgroundColor(canNext: Bool) {
        if canNext {
            loginPhoneNumberButton.backgroundColor = .appColor
            loginPhoneNumberButton.titleLabel?.layer.opacity = 1
            loginPhoneNumberButton.isUserInteractionEnabled = true
        } else {
            loginPhoneNumberButton.backgroundColor = isDark ? .systemGray6 : .systemGray5
            if isDark {
                loginPhoneNumberButton.titleLabel?.layer.opacity = 0.4
            }
            loginPhoneNumberButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Light / Dark mode
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .light:
            if !loginPhoneNumberButton.isUserInteractionEnabled {
                loginPhoneNumberButton.backgroundColor = .systemGray5
                loginPhoneNumberButton.titleLabel?.layer.opacity = 1
            }
            loginWebasystButton.layer.borderColor = UIColor.systemGray5.cgColor
            loginQRButton.layer.borderColor = UIColor.systemGray5.cgColor
            loginAppleIDButton.layer.borderColor = UIColor.systemGray5.cgColor
            loadingView.layer.borderColor = UIColor.systemGray2.cgColor
        case .dark, .unspecified:
            if !loginPhoneNumberButton.isUserInteractionEnabled {
                loginPhoneNumberButton.backgroundColor = .systemGray6
                loginPhoneNumberButton.titleLabel?.layer.opacity = 0.4
            }
            loginWebasystButton.layer.borderColor = UIColor.systemGray6.cgColor
            loginQRButton.layer.borderColor = UIColor.systemGray6.cgColor
            loginAppleIDButton.layer.borderColor = UIColor.systemGray6.cgColor
            loadingView.layer.borderColor = UIColor.systemGray4.cgColor
        @unknown default:
            break
        }
    }
}
