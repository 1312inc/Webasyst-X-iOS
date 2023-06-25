//
//  RedactorView.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.10.2022.
//

import UIKit
import Webasyst
import libPhoneNumber_iOS

protocol RedactorInteractive: AnyObject {
    func save(_ profile: ProfileData)
    func remove()
    func newImage()
    func later()
    func delete()
}

enum RedactorUpdate {
    case image(UIImage)
    case remove
    case profile(ProfileData)
    case delete(Bool?)
}

class RedactorView: UIView, UIDeviceShared {
    
    public var countryForParsing = ""
    private var phoneInstance: NBPhoneNumberUtil {
        get {
            guard let instance = NBPhoneNumberUtil.sharedInstance() else {
                return NBPhoneNumberUtil.init()
            }
            return instance
        }
    }
    
    weak var delegate: RedactorInteractive?
    let laterNeeded: Bool
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let contentView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.color = .appColor
        return activityIndicatorView
    }()
    
    fileprivate lazy var aboutSameself: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .adaptiveFont(.headline, 17, .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    fileprivate lazy var profileImageView: ProfileImageView = {
        let piv = ProfileImageView(delegate: self)
        piv.translatesAutoresizingMaskIntoConstraints = false
        piv.isHidden = true
        piv.alpha = 0
        return piv
    }()
    
    fileprivate lazy var addPhotoLabel: UIButton = {
        let button = UIButton()
        button.setTitleColor(.appColor, for: .normal)
        button.setTitleColor(.appColor.withAlphaComponent(0.5), for: .highlighted)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = .adaptiveFont(.body, 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var removeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .adaptiveFont(.body, 15)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.red.withAlphaComponent(0.5), for: .highlighted)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(remove), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = .getLocalizedString(withKey: "name")
        textField.textColor = .label
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    fileprivate var surnameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = .getLocalizedString(withKey: "surname")
        textField.textColor = .label
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    fileprivate var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "E-mail"
        textField.textColor = .label
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    fileprivate lazy var phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = .getLocalizedString(withKey: "phone")
        textField.textColor = .label
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = .appColor
        button.addTarget(self, action: #selector(save), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var lateButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.setTitleColor(.appColor, for: .normal)
        button.setTitleColor(.appColor.withAlphaComponent(0.5), for: .highlighted)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemGray.withAlphaComponent(0.1)
        button.addTarget(self, action: #selector(later), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var deleteAccountButton: UIButton = {
        let button = UIButton()
        let text = String.getLocalizedString(withKey: "deleteAccount")
        button.titleLabel?.font = .adaptiveFont(.subheadline, 15, .semibold)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.appColor, for: .normal)
        button.setTitleColor(.appColor.withAlphaComponent(0.5), for: .highlighted)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(deleteAcc), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(frame: CGRect, laterNeeded: Bool) {
        self.laterNeeded = laterNeeded
        super.init(frame: frame)
        backgroundColor = UIColor.backgroundColor
        setText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        bottomLine([nameTextField,surnameTextField,emailTextField,phoneTextField])
        activityIndicator.frame = imageView.frame
        activityIndicator.center = imageView.center
    }
    
    func setText() {
        removeButton.setTitle(.getLocalizedString(withKey: "removePhoto"), for: .normal)
        if laterNeeded {
            aboutSameself.text = .getLocalizedString(withKey: "aboutSameself")
            lateButton.setTitle(.getLocalizedString(withKey: "specifyLater"), for: .normal)
            addPhotoLabel.setTitle(.getLocalizedString(withKey: "addPhoto"), for: .normal)
        } else {
            addPhotoLabel.setTitle(.getLocalizedString(withKey: "changePhoto"), for: .normal)
        }
        saveButton.setTitle(.getLocalizedString(withKey: "save"), for: .normal)
    }
    
    func setDefaults(_ profile: ProfileData?) {
        if let profile = profile {
            imageView.image = UIImage(data: profile.userpic_original_crop ?? .init())
            updateProfileImage(UIImage(data: profile.userpic_original_crop ?? .init()))
            nameTextField.text = profile.firstname
            surnameTextField.text = profile.lastname
            emailTextField.text = profile.email
            self.countryForParsing = self.getCountryCode("+\(profile.phone)")
            let phone = self.extractPhone(profile.phone)
            phoneTextField.text = phone
            layout()
        }
    }
    
    func updateProfileImage(_ image: UIImage?) {
        profileImageView.profileImage = image
    }
    
    func layout() {
        
        addSubview(scrollView)
        
        addSubview(profileImageView)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(addPhotoLabel)
        contentView.addSubview(saveButton)
        contentView.addSubview(nameTextField)
        contentView.addSubview(surnameTextField)
        contentView.addSubview(activityIndicator)
        
        if laterNeeded {
            contentView.addSubview(aboutSameself)
            contentView.addSubview(lateButton)
        } else {
            contentView.addSubview(deleteAccountButton)
            contentView.addSubview(removeButton)
            contentView.addSubview(emailTextField)
            contentView.addSubview(phoneTextField)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
        
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(scrollView.snp.height)
            make.width.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(100)
            if laterNeeded {
                make.top.equalTo(aboutSameself.snp.bottom).offset(20)
            } else {
                make.top.equalTo(contentView.snp.top).offset(15)
            }
            make.centerX.equalToSuperview()
        }
        
        addPhotoLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(laterNeeded ? nameTextField.snp.top : removeButton.snp.top).offset(-10)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(55)
            make.bottom.equalTo(surnameTextField.snp.top)
        }
        
        surnameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(55)
            make.width.equalToSuperview().multipliedBy(0.9)
            if laterNeeded {
                make.bottom.equalTo(saveButton.snp.top).offset(-20)
            }
        }
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(50)
            if laterNeeded {
                make.bottom.equalTo(lateButton.snp.top).offset(-15)
            } else {
                make.bottom.lessThanOrEqualTo(deleteAccountButton.snp.top).offset(-15)
            }
        }
        
        if laterNeeded {
            
            aboutSameself.snp.makeConstraints { make in
                make.top.equalTo(isSmall || isMedium ? contentView.snp.top : contentView.snp.top).offset(5)
                make.centerX.equalToSuperview()
                make.height.equalTo(20)
                make.left.right.equalToSuperview()
            }
            
            lateButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(50)
                make.width.equalToSuperview().multipliedBy(0.9)
                make.bottom.lessThanOrEqualToSuperview().offset(isPlus || isMedium || isSmall ? -15 : 0)
            }
            
        } else {
            
            emailTextField.snp.makeConstraints { make in
                make.height.equalTo(55)
                make.top.equalTo(surnameTextField.snp.bottom)
                make.width.equalToSuperview().multipliedBy(0.9)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(phoneTextField.snp.top)
            }
            
            phoneTextField.snp.makeConstraints { make in
                make.height.equalTo(55)
                make.top.equalTo(emailTextField.snp.bottom)
                make.width.equalToSuperview().multipliedBy(0.9)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(saveButton.snp.top).offset(-20)
            }
            
            removeButton.snp.makeConstraints { make in
                make.height.equalTo(25)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(nameTextField.snp.top)
            }
            
            deleteAccountButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(contentView.snp.bottom).offset(isPlus || isMedium || isSmall ? -15 : 0)
            }
            
        }
        
        layoutIfNeeded()
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openImage))
        imageView.addGestureRecognizer(tap)
    }
    
    func bottomLine(_ tf: [UITextField]) {
        for field in tf {
            for sublayer in field.layer.sublayers ?? [] {
                if sublayer.backgroundColor == UIColor.gray.withAlphaComponent(0.3).cgColor {
                    sublayer.removeFromSuperlayer()
                }
            }
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(x: 0.0, y: field.frame.height - 5, width: field.frame.width, height: 1.0)
            bottomLine.backgroundColor = UIColor.gray.withAlphaComponent(0.3).cgColor
            field.layer.addSublayer(bottomLine)
        }
    }
    
    public func startLoading() {
        imageView.layer.opacity = 0.5
        activityIndicator.startAnimating()
    }
    
    public func endLoading() {
        imageView.layer.opacity = 1
        activityIndicator.stopAnimating()
    }
    
    @objc func save() {
        if let firstName = nameTextField.text,
           let lastName = surnameTextField.text,
           let email = emailTextField.text,
           let phone = phoneTextField.text {
            let profile = ProfileData(name: "",
                                      firstname: firstName,
                                      lastname: lastName,
                                      middlename: "",
                                      email: email,
                                      phone: phone,
                                      userpic_original_crop: imageView.image?.pngData())
            delegate?.save(profile)
        }
    }
    
    @objc func later() {
        delegate?.later()
    }
    
    @objc func selectImage() {
        delegate?.newImage()
    }
    
    @objc func remove() {
        delegate?.remove()
    }
    
    @objc func deleteAcc() {
        delegate?.delete()
    }
    
}

// MARK: - Keyboard actions

extension RedactorView {
    
    @objc func keyboardWasShown(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo
        let value = info?[UIResponder.keyboardFrameEndUserInfoKey]
        if let rawFrame = (value as AnyObject).cgRectValue {
            let keyboardFrame = scrollView.convert(rawFrame, from: nil)
            let keyboardHeight = keyboardFrame.height
            
            self.constraints.forEach { constraint in
                if (constraint.secondAttribute == .bottom && constraint.secondItem is UIScrollView) || (constraint.firstAttribute == .bottom && constraint.firstItem is UIScrollView) {
                    constraint.isActive = false
                }
            }
            
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -keyboardHeight).isActive = true
            if laterNeeded {
                lateButton.snp.updateConstraints { make in
                    make.bottom.lessThanOrEqualToSuperview().offset(isPlus || isMedium || isSmall ? -30 : -15)
                }
            } else {
                deleteAccountButton.snp.updateConstraints { make in
                    make.bottom.equalTo(contentView.snp.bottom).offset(isPlus || isMedium || isSmall ? -30 : -15)
                }
            }
            
            layoutIfNeeded()
            
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    @objc func keyboardWasHidden(_ notification: Notification) {
        
        self.constraints.forEach { constraint in
            if (constraint.secondAttribute == .bottom && constraint.secondItem is UIScrollView) || (constraint.firstAttribute == .bottom && constraint.firstItem is UIScrollView) {
                constraint.isActive = false
            }
        }
        
        scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        if laterNeeded {
            lateButton.snp.updateConstraints { make in
                make.bottom.lessThanOrEqualToSuperview().offset(isPlus || isMedium || isSmall ? -15 : 0)
            }
        } else {
            deleteAccountButton.snp.updateConstraints { make in
                make.bottom.equalTo(contentView.snp.bottom).offset(isPlus || isMedium || isSmall ? -15 : 0)
            }
        }
        
        layoutIfNeeded()
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
}

extension RedactorView: ProfileImageViewDelegate {
    
    @objc private func openImage() {
        profileImageView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.profileImageView.alpha = 1
        }
    }
    
    func hideImage(_ completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0.2) {
            self.profileImageView.alpha = 0
        } completion: { _ in
            self.profileImageView.isHidden = true
            completion()
        }
    }
}

extension RedactorView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField === phoneTextField, let text = textField.text {
            
            let countryCode: String
            if text.first == "8" {
                countryCode = "RU2"
            } else {
                countryCode = getCountryCode("+\(text.dropFirst())")
            }
            
            if countryCode.isEmpty {
                return true
            } else {
                
                let newText: String
                if countryCode == "RU2" {
                    newText = text
                } else {
                    newText = "+\(text)"
                }
                
                countryForParsing = countryCode
                if range.length == .zero {
                    let phone = self.extractPhone(newText + string)
                    textField.text = phone
                    return false
                } else {
                    return true
                }
            }
        } else {
            return true
        }
    }
}

extension RedactorView {
    
    public func getCountryCode(_ number: String) -> String {
        guard let parsedCountryCode = parser(number)?.countryCode,
              let phone = phoneInstance.getRegionCode(forCountryCode: parsedCountryCode) else { return "" }
        return phone
    }
    
    public func parser(_ number: String) -> NBPhoneNumber? {
        do {
            let parsedNumber = try phoneInstance.parse(number, defaultRegion: nil)
            return parsedNumber
        } catch {
            return nil
        }
    }
    
    public func extractPhone(_ number: String) -> String {
        if let path = Bundle.main.path(forResource: "mask", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                     let country = jsonResult[countryForParsing] as? String {
                        return format(with: country, phone: number)
                  }
              } catch {
                   return ""
              }
        }
        return number
    }

    public func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex

        let newMask = mask.reduce("", {
            if $1.isNumber {
                return $0 + "#"
            } else if $1 == "(" {
                return $0 + " " + [$1]
            } else if $1 == ")" {
                return $0 + [$1] + " "
            } else {
                return $0 + [$1]
            }
        })

        for ch in newMask where index < numbers.endIndex {
            if ch == "#" {
                result.append(numbers[index])

                index = numbers.index(after: index)

            } else {
                result.append(ch)
            }
        }
        return result
    }
}
