//
//  FooterView.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol FooterViewSettingsListDelegate: AnyObject {
    func openAddNewAccount()
    func openManager()
    func openPasscode()
}

class FooterView: UIView {
    
    weak var delegate: FooterViewSettingsListDelegate?
    
    lazy var addWebasystButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 10
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.label.withAlphaComponent(0.5), for: .highlighted)
        button.contentHorizontalAlignment = .center
        button.setTitle(.getLocalizedString(withKey: "addWebasystButton"), for: .normal)
        button.titleLabel?.font = .adaptiveFont(.subheadline, 17, .semibold)
        button.addTarget(self, action: #selector(openAddNewAccountTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var manageProfileButton: UIButton = {
        let button = UIButton()
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
            button.configuration = config
        } else {
            button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
        
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 10
        button.setTitleColor(.appColor, for: .normal)
        button.setTitleColor(.appColor.withAlphaComponent(0.5), for: .highlighted)
        button.contentHorizontalAlignment = .center
        button.setTitle(.getLocalizedString(withKey: "manageProfileButton"), for: .normal)
        button.titleLabel?.font = .adaptiveFont(.subheadline, 17, .semibold)
        button.addTarget(self, action: #selector(openManager), for: .touchUpInside)
        return button
    }()
    
    lazy var setPinCodeButton: UIButton = {
        let button = UIButton()
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
            button.configuration = config
        } else {
            button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
        
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 10
        button.setTitleColor(.appColor, for: .normal)
        button.setTitleColor(.appColor.withAlphaComponent(0.5), for: .highlighted)
        button.contentHorizontalAlignment = .center
        button.setTitle(.getLocalizedString(withKey: "setPinCodeButton"), for: .normal)
        button.titleLabel?.font = .adaptiveFont(.subheadline, 17, .semibold)
        button.addTarget(self, action: #selector(setPinCodeTapped), for: .touchUpInside)
        return button
    }()
    
    private var disposeBag = DisposeBag()
    
    init(frame: CGRect, delegate: FooterViewSettingsListDelegate) {
        self.delegate = delegate
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        addSubview(addWebasystButton)
        addSubview(stackView)
        stackView.addArrangedSubview(manageProfileButton)
        stackView.addArrangedSubview(setPinCodeButton)
        
        addWebasystButton.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.top.equalTo(self).offset(10)
            make.height.equalTo(50)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(addWebasystButton.snp.bottom).offset(48)
            make.height.equalTo(50)
        }
        
        layoutIfNeeded()
        
        manageProfileButton.layer.cornerRadius = manageProfileButton.frame.height / 5
        setPinCodeButton.layer.cornerRadius = setPinCodeButton.frame.height / 5
    }
    
    @objc private func openAddNewAccountTap() {
        delegate?.openAddNewAccount()
    }
    
    @objc fileprivate func openManager() {
        delegate?.openManager()
    }

    @objc fileprivate func setPinCodeTapped() {
        delegate?.openPasscode()
    }
}
