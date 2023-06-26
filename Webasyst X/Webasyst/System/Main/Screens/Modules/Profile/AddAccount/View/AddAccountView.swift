//
//  AddAccountView.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.10.2022.
//

import UIKit

protocol AddAccountDelegate: AnyObject {
    func linkAccountWithQR()
    func linkAccount()
    func connectAccount(withDigitalCode: String, completion: @escaping (Bool) -> ())
    func addAccount(shopDomain: String?, shopName: String?, startLoading: @escaping () -> (), stopLoading: @escaping () -> (), completion: @escaping (Bool) -> ())
}

class AddAccountView: UIView, UIDeviceShared {
    
    public weak var delegate: AddAccountDelegate?
    fileprivate var presented: Bool
    fileprivate var layoutSubviewsIsSet: Bool = false
    fileprivate var codeTFDidChange: Bool = false
    fileprivate var descriptionOfStoreConnectText: String?
    fileprivate var currentBottomInset: CGFloat = 48
    
    init(bottomBlock: Bool) {
        self.presented = bottomBlock
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    fileprivate let titleOfStoreConnectLabel: UILabel = {
        var label = UILabel()
        let text = String.getLocalizedString(withKey: "createInstallTitleOfStoreConnect")
        label.font = .adaptiveFont(.largeTitle, 22, .bold)
        label.textColor = .label
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let descriptionOfStoreConnectLabel: UILabel = {
        var label = UILabel()
        
        let attributedString = NSMutableAttributedString(string: .getLocalizedString(withKey: "createInstallDescriptionOfStoreConnect"))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        
        label.font = .adaptiveFont(.body, 15)
        label.textColor = .systemGray2
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var codeStackView: UIStackView = {
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
    
    public lazy var topLayerOfCodeStackView: UIView = {
        let view = UIView()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(codeStackViewPressed))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    fileprivate let newShopTitleLabel: UILabel = {
        var label = UILabel()
        label.font = .adaptiveFont(.largeTitle, 22, .bold)
        label.text = .getLocalizedString(withKey: "createNewShopTitle")
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var newShopNameTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: localizedStringFor(key: "installNamePlaceholder", comment: ""),
                                                      attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.3)])
        tf.font = .adaptiveFont(.body, 15)
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.backgroundColor = .white
        tf.textAlignment = .center
        tf.layer.cornerRadius = 10
        tf.textColor = .black
        tf.tintColor = .appColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        return tf
    }()
    
    public lazy var newShopNameLabel: UILabel = {
        let label = UILabel()
        
        let firstString = NSMutableAttributedString(string: "yourcompany", attributes: [.foregroundColor: UIColor.tintColor,
                                                                                        .font: UIFont.adaptiveFont(.body, 15, .bold)])
        let secondString = NSMutableAttributedString(string: ".webasyst.cloud", attributes: [.foregroundColor: UIColor.label,
                                                                                             .font: UIFont.adaptiveFont(.body, 15, .medium)])
        firstString.append(secondString)
        
        label.attributedText = firstString
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byClipping
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public lazy var newShopButton: UIButton = {
        var button = UIButton()
        button.isEnabled = false
        button.alpha = 0.5
        let text = String.getLocalizedString(withKey: "createInstallButton")
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.backgroundColor = .appColor
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate let newShopDescriptionLabel: UILabel = {
        var label = UILabel()
        
        let attributedString = NSMutableAttributedString(string: .getLocalizedString(withKey: "createNewShopDescription"))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        
        label.font = .adaptiveFont(.body, 15)
        label.textColor = .systemGray2
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var aboutEightDigitCode: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 10
        let image = UIImage(systemName: "questionmark")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
        button.addTarget(self, action: #selector(showInfoAboutEightDigitCode), for: .touchUpInside)
        return button
    }()
    
    fileprivate let joinDescriptionLabel: UILabel = {
        var label = UILabel()
        
        let attributedString = NSMutableAttributedString(string: .getLocalizedString(withKey: "joinDescriptionOnlyQR"))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        
        label.font = .adaptiveFont(.body, 15)
        label.textColor = .systemGray2
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var loginQRButton: UIButton = {
        let button = UIButton()
        
        let text = String.getLocalizedString(withKey: "QRAdd")
        button.setTitle(text, for: .normal)
        
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
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    fileprivate lazy var linkWebasystButton: UIButton = {
        var button = UIButton()
        
        let text = String.getLocalizedString(withKey: "emailLogin")
        button.setTitle(text, for: .normal)
        
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.systemGray2, for: .highlighted)
        
        button.layer.cornerRadius = 10
        button.layer.borderColor = isDark ? UIColor.systemGray6.cgColor : UIColor.systemGray5.cgColor
        button.layer.borderWidth = 2
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        
        let image = UIImage(named: "magic-wand-small")
        let highlightedImage = UIImage(named: "magic-wand-small")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setImage(highlightedImage, for: .highlighted)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = .systemGray2
        
        button.addTarget(self, action: #selector(linkAccount), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    fileprivate lazy var aboutWebasystID: UIButton = {
        var button = UIButton()
        
        let text = String.getLocalizedString(withKey: "aboutWebAsystID")
        button.setTitle(text, for: .normal)
        
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.setTitleColor(.appColor, for: .normal)
        button.setTitleColor(.appColor.withAlphaComponent(0.5), for: .highlighted)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openAboutWebasyst), for: .touchUpInside)
        
        return button
    }()

    fileprivate let backgroundView: UIView = {
        var view = UIView()
        view.backgroundColor = .appColor.withAlphaComponent(0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let checkerImageView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(systemName: "checkmark.circle")
        
        view.image = image
        view.contentMode = .scaleAspectFit
        view.tintColor = .systemGreen
        
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
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
        loadingView.alpha = 0
        loadingView.isHidden = true
        loadingView.layer.cornerRadius = 100 / 8
        loadingView.backgroundColor = .reverseLabel
        loadingView.layer.borderColor = isDark ? UIColor.systemGray4.cgColor : UIColor.systemGray2.cgColor
        loadingView.layer.borderWidth = 3
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }()
    
    func configure(email: String?) {
        
        layoutSubviews()
        
        if let email = email, email != "" {
            descriptionOfStoreConnectText = descriptionOfStoreConnectLabel.text?.replacingOccurrences(of: "%ACCOUNTEMAIL%", with: " (\(email))")
        } else {
            descriptionOfStoreConnectText = descriptionOfStoreConnectLabel.text?.replacingOccurrences(of: "%ACCOUNTEMAIL%", with: "")
        }
        
        if !presented {
            newShopButton.addTarget(self, action: #selector(addAccount), for: .touchUpInside)
            loginQRButton.addTarget(self, action: #selector(linkWithQR), for: .touchUpInside)
        }
        
        if presented {
            if let text = descriptionOfStoreConnectText {
                
                let attributedString = NSMutableAttributedString(string: text)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 2
                paragraphStyle.alignment = .center
                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                
                descriptionOfStoreConnectLabel.attributedText = attributedString
            }
        } else {
            
            var attributedString = NSMutableAttributedString(string: .getLocalizedString(withKey: "createInstallNotPresentedDescriptionOfStoreConnect"))
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.alignment = .center
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            
            descriptionOfStoreConnectLabel.attributedText = attributedString
            
            attributedString = NSMutableAttributedString(string: .getLocalizedString(withKey: "joinDescription"))
            paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.alignment = .center
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            
            joinDescriptionLabel.attributedText = attributedString
        }
        
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
        contentView.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public func clearCodeTF() {
        
        for stackView in codeStackView.subviews {
            for tf in stackView.subviews {
                if let tf = tf as? UITextField {
                    tf.text = nil
                }
            }
        }
    }
    
    override func layoutSubviews() {
        
        if !layoutSubviewsIsSet {
            layoutSubviewsIsSet = true
        } else {
            layoutIfNeeded()
            return
        }
        
        backgroundColor = .reverseLabel
        parentViewController?.navigationItem.largeTitleDisplayMode = .never
        parentViewController?.navigationController?.navigationBar.prefersLargeTitles = false
        parentViewController?.navigationController?.appearanceColor(color: .reverseLabel)
        
        addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(titleOfStoreConnectLabel)
        contentView.addSubview(descriptionOfStoreConnectLabel)
        contentView.addSubview(codeStackView)
        contentView.addSubview(topLayerOfCodeStackView)
        contentView.addSubview(joinDescriptionLabel)
        contentView.addSubview(loginQRButton)
        
        contentView.addSubview(backgroundView)
        backgroundView.addSubview(newShopTitleLabel)
        backgroundView.addSubview(newShopNameTextField)
        backgroundView.addSubview(checkerImageView)
        backgroundView.addSubview(newShopNameLabel)
        backgroundView.addSubview(newShopButton)
        backgroundView.addSubview(newShopDescriptionLabel)
        
        if presented {

            descriptionOfStoreConnectLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(24)
                make.trailing.equalToSuperview().inset(24)
            }

            backgroundView.snp.makeConstraints { make in
                make.top.greaterThanOrEqualTo(loginQRButton.snp.bottom).offset(24)
            }
        } else {
            contentView.addSubview(aboutEightDigitCode)
            contentView.addSubview(linkWebasystButton)
            contentView.addSubview(aboutWebasystID)
            
            descriptionOfStoreConnectLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
            }
            
            aboutEightDigitCode.snp.makeConstraints { make in
                make.leading.equalTo(descriptionOfStoreConnectLabel.snp.trailing).offset(4)
                make.centerY.equalTo(descriptionOfStoreConnectLabel)
                make.width.height.equalTo(20)
            }
            
            linkWebasystButton.snp.makeConstraints { make in
                make.top.equalTo(loginQRButton.snp.bottom).offset(12)
                make.width.equalToSuperview().multipliedBy(0.85)
                make.centerX.equalToSuperview()
                make.height.equalTo(newShopButton.snp.height)
            }
            
            aboutWebasystID.snp.makeConstraints { make in
                make.top.equalTo(linkWebasystButton.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
            }
            
            backgroundView.snp.makeConstraints { make in
                make.top.greaterThanOrEqualTo(aboutWebasystID.snp.bottom).offset(24)
            }
        }
        
        contentView.addSubview(overlayView)
        contentView.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        contentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(scrollView.snp.height)
            make.width.equalToSuperview()
        }
        
        titleOfStoreConnectLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(4)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().inset(32)
        }

        descriptionOfStoreConnectLabel.snp.makeConstraints { make in
            make.top.equalTo(titleOfStoreConnectLabel.snp.bottom).offset(16)
        }

        let width = "4".width(by: .adaptiveFont(.body, 22, .bold)) * 8 + 6 * 8 + 48
        codeStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionOfStoreConnectLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(56)
            make.width.equalTo(width)
        }
        
        topLayerOfCodeStackView.snp.makeConstraints { make in
            make.edges.equalTo(codeStackView)
        }
        
        joinDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(codeStackView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
        }
        
        loginQRButton.snp.makeConstraints { make in
            make.top.equalTo(joinDescriptionLabel.snp.bottom).offset(12)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
            make.height.equalTo(newShopButton.snp.height).offset(loginQRButton.layer.borderWidth)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        newShopTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.snp.top).offset(28)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().inset(32)
        }

        newShopNameTextField.snp.makeConstraints { make in
            make.top.equalTo(newShopTitleLabel.snp.bottom).offset(16)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
            make.height.equalTo(newShopButton.snp.height).offset(newShopNameTextField.layer.borderWidth)
        }
        
        checkerImageView.snp.makeConstraints { make in
            make.trailing.equalTo(newShopNameTextField.snp.trailing).inset(12)
            make.top.bottom.equalTo(newShopNameTextField).inset(12)
        }

        newShopNameLabel.snp.makeConstraints { make in
            make.top.equalTo(newShopNameTextField.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().inset(32)
        }

        newShopButton.snp.makeConstraints { make in
            make.top.equalTo(newShopNameLabel.snp.bottom).offset(16)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }

        newShopDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(newShopButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(64)
        }
        
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(loadingView.snp.width)
        }
        
        layoutIfNeeded()
        
        var maxY: CGFloat
        if presented {
            maxY = loginQRButton.frame.maxY
        } else {
            maxY = aboutWebasystID.frame.maxY
        }
        
        if backgroundView.frame.minY - maxY <= 25 {
            currentBottomInset = 16
            newShopDescriptionLabel.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(24)
            }
        }
    }
    
    @objc fileprivate func linkWithQR() {
        delegate?.linkAccountWithQR()
    }
    
    @objc fileprivate func linkAccount() {
        delegate?.linkAccount()
    }
    
    fileprivate func connectAccount(withDigitalCode code: String) {
        
        guard let delegate = self.delegate else { return }
        
        topLayerOfCodeStackView.isUserInteractionEnabled = false
        
        delegate.connectAccount(withDigitalCode: code, completion: {
            if !$0 {
                self.topLayerOfCodeStackView.isUserInteractionEnabled = true
            }
        })
    }
    
    private func startAddAccountLoading() {
        overlayView.isHidden = false
        loadingView.isHidden = false
        loadingView.startAnimating()
        UIView.animate(withDuration: 0.1) {
            self.overlayView.alpha = 1
            self.loadingView.alpha = 1
        }
    }
    
    private func stopAddAccountLoading() {
        UIView.animate(withDuration: 0.1) {
            self.overlayView.alpha = 0
            self.loadingView.alpha = 0
        } completion: { _ in
            self.loadingView.stopAnimating()
            self.overlayView.isHidden = true
            self.loadingView.isHidden = true
        }
    }
    
    @objc fileprivate func addAccount() {
        self.endEditing(true)
        self.newShopButton.isUserInteractionEnabled = false
        self.newShopButton.backgroundColor = .systemGray3
        
        if let shopDomain = newShopNameLabel.text?.components(separatedBy: ".").first {
            delegate?.addAccount(shopDomain: shopDomain, shopName: newShopNameTextField.text, startLoading: {
                self.startAddAccountLoading()
            }, stopLoading: {
                self.stopAddAccountLoading()
            }, completion: {
                if !$0 {
                    self.newShopButton.isUserInteractionEnabled = true
                    self.newShopButton.backgroundColor = .appColor
                }
            })
        } else if let vc = self.parentViewController {
            vc.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"),
                         description: .getLocalizedString(withKey: "shopNameErrorDescription"),
                         analytics: AnalyticsModel(type: "app", debugInfo: debug(), method: "addAccountShopDomain"))
        }
    }
    
    @objc fileprivate func openAboutWebasyst() {
        let url = String.getLocalizedString(withKey: "webasystURL")
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc fileprivate func showInfoAboutEightDigitCode() {
        DispatchQueue.main.async {
            
            var message: String
            if let text = self.descriptionOfStoreConnectText {
                message = text + "."
            } else {
                message = ""
            }
            
            if let vc = self.parentViewController {
                vc.showAlert(withTitle: .getLocalizedString(withKey: "showInfoAboutEightDigitCodeTitle"),
                             description: message)
            }
        }
    }
    
    fileprivate func width(font: UIFont, text: String?) -> CGFloat {
        
        guard let text = text else {
            return 0
        }
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: fontAttributes).width + 25
    }
}

// MARK: - Code stack view

extension AddAccountView: UITextFieldDelegate {
    
    fileprivate func getAttributedName(withText text: String = "yourcompany") -> NSMutableAttributedString {
        
        let transliteratedText = text.lowercased().transliterate()
        let range = NSRange(location: 0, length: text.count - transliteratedText.filter({ $0 == "ʹ" }).count)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.adaptiveFont(.body, 15, .bold)]
        
        let attributedString = NSMutableAttributedString(string: "\(transliteratedText.replacingOccurrences(of: "ʹ", with: "")).webasyst.cloud", attributes: attributes)
        attributedString.addAttribute(.foregroundColor, value: UIColor.tintColor, range: range)
        
        let defaultRange = NSRange(location: range.upperBound, length: attributedString.length - range.length)
        attributedString.addAttribute(.font, value: UIFont.adaptiveFont(.body, 15, .medium), range: defaultRange)
        
        return attributedString
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField === newShopNameTextField {
            
            let oldStr = textField.text as? NSString
            let newStr = oldStr?.replacingCharacters(in: range, with: string)
            
            let availableCharacters: CharacterSet = .letters.union(.alphanumerics).union(.whitespaces).inverted
            
            if let newStr = newStr, newStr != "", newStr.first != " ", newStr.first?.lowercased() != "ь", newStr.rangeOfCharacter(from: availableCharacters) == nil {
                self.newShopButton.isEnabled = true
                self.newShopButton.alpha = 1
                self.checkerImageView.image = UIImage(systemName: "checkmark.circle")
                self.checkerImageView.tintColor = .systemGreen
                self.checkerImageView.isHidden = false
                self.newShopNameLabel.attributedText = self.getAttributedName(withText: newStr)
            } else if let newStr = newStr, newStr != "" {
                self.newShopButton.isEnabled = false
                self.newShopButton.alpha = 0.5
                self.checkerImageView.image = UIImage(systemName: "x.circle")
                self.checkerImageView.tintColor = .red
                self.checkerImageView.isHidden = false
            } else {
                self.newShopButton.isEnabled = false
                self.newShopButton.alpha = 0.5
                self.checkerImageView.image = UIImage(systemName: "checkmark.circle")
                self.checkerImageView.tintColor = .systemGreen
                self.checkerImageView.isHidden = true
                self.newShopNameLabel.attributedText = self.getAttributedName()
            }
            
            return true
        }
        
        if string != "" {
            
            var code: String = ""
            
            for (i, stackView) in codeStackView.subviews.enumerated() {
                for (j, tf) in stackView.subviews.enumerated() {
                    if let tf = tf as? UITextField {
                        
                        code += tf.text ?? ""
                        
                        if tf.text == nil || tf.text?.isEmpty ?? true {
                            
                            tf.text = string
                            codeTFDidChange = true
                            tf.becomeFirstResponder()
                            if i == 1 && j == 3 {
                                
                                code += tf.text ?? ""
                                
                                // Send code
                                
                                self.connectAccount(withDigitalCode: code)
                                let vc = self.parentViewController as? AddAccountViewController
                                vc?.viewModel.input.digitalCode.accept(code)
                                
                                self.endEditing(true)
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
                            codeTFDidChange = true
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
    
    @objc private func codeStackViewPressed() {
        
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

// MARK: - Keyboard methods

extension AddAccountView {
    
    @objc private func hideKeyboard() {
        self.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @objc func keyboardWasShown(_ notification: Notification) {
        
        if codeTFDidChange {
            codeTFDidChange = false
            return
        }
        
        let info = (notification as NSNotification).userInfo
        let value = info?[UIResponder.keyboardFrameEndUserInfoKey]
        if let rawFrame = (value as AnyObject).cgRectValue {
            let keyboardFrame = self.scrollView.convert(rawFrame, from: nil)
            let keyboardHeight = keyboardFrame.height
            
            self.constraints.forEach { constraint in
                if constraint.secondAttribute == .bottom || constraint.firstAttribute == .bottom {
                    constraint.isActive = false
                }
            }
            
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -keyboardHeight).isActive = true
            layoutIfNeeded()
            
            var bottomOffset: CGPoint
            if newShopNameTextField.isFirstResponder {
                bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom - currentBottomInset)
            } else {
                bottomOffset = CGPoint(x: 0, y: 0)
            }
            
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    @objc func keyboardWasHidden(_ notification: Notification) {
        
        self.constraints.forEach { constraint in
            if constraint.secondAttribute == .bottom || constraint.firstAttribute == .bottom {
                constraint.isActive = false
            }
        }
        
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        layoutIfNeeded()
        
        var bottomOffset: CGPoint
        if newShopNameTextField.isFirstResponder {
            bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        } else {
            bottomOffset = CGPoint(x: 0, y: 0)
        }
        
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
}

// MARK: - Light / Dark mode

extension AddAccountView {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .light:
            linkWebasystButton.layer.borderColor = UIColor.systemGray5.cgColor
            loginQRButton.layer.borderColor = UIColor.systemGray5.cgColor
            loadingView.layer.borderColor = UIColor.systemGray2.cgColor
        case .dark, .unspecified:
            linkWebasystButton.layer.borderColor = UIColor.systemGray6.cgColor
            loginQRButton.layer.borderColor = UIColor.systemGray6.cgColor
            loadingView.layer.borderColor = UIColor.systemGray4.cgColor
        @unknown default:
            break
        }
    }
}
