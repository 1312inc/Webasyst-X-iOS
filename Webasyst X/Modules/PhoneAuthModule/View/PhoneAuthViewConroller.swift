//
//  PhoneAuth module - PhoneAuthViewConroller.swift
//  Teamwork
//
//  Created by viktkobst on 20/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PhoneAuthViewController: UIViewController {

    //MARK: ViewModel property
    var viewModel: PhoneAuthViewModel?
    var coordinator: PhoneAuthCoordinator?
    
    private var disposeBag = DisposeBag()
    
    //MARK: Interface elements property
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("titlePhone", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("descriptionPhone", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var phoneField: JMMaskTextField = {
        let textField = JMMaskTextField()
        textField.keyboardType = .phonePad
        textField.placeholder = "+7 (777) 777-77-77"
        textField.maskString = "+0 (000) 000-00-00"
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("nextButton", comment: ""), for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        return button
    }()
        
    private var regex = try! NSRegularExpression(pattern: "[\\+\\s-\\(\\)]", options: .caseInsensitive)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = UIColor(named: "backgroundColor")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextButton)
        phoneField.becomeFirstResponder()
        self.setupLayout()
        self.bindableViewModel()
    }
    
    private func bindableViewModel() {
        guard let viewModel = self.viewModel else { return }
        
        nextButton.rx.tap
            .bind(to: viewModel.input.nextButtonTap)
            .disposed(by: disposeBag)
        
        viewModel.output.showLoadingHub
            .subscribe(onNext: { [weak self] loading in
                guard let self = self else { return }
                if loading {
                    DispatchQueue.main.async {
                        self.nextButton.isUserInteractionEnabled = loading
                    }
                } else {
                    DispatchQueue.main.async {
                        self.nextButton.isUserInteractionEnabled = loading
                    }
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.submitButtonEnabled
            .subscribe(onNext: { [weak self] enabled in
                guard let self = self else { return }
                if enabled {
                    self.nextButton.setTitleColor(UIColor.systemBlue, for: .normal)
                    self.nextButton.isUserInteractionEnabled = true
                } else {
                    self.nextButton.setTitleColor(UIColor.systemGray, for: .normal)
                    self.nextButton.isUserInteractionEnabled = false
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.showLoadingHub
            .subscribe(onNext: { [weak self] show in
                guard let self = self else { return }
                if show {
                    DispatchQueue.main.async {
                        let uiBusy = UIActivityIndicatorView()
                        uiBusy.hidesWhenStopped = true
                        uiBusy.startAnimating()
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.nextButton)
                    }
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.serverStatus
            .subscribe(onNext: { [weak self] status in
                guard let self = self else { return }
                guard let coordinator = self.coordinator else { return }
                switch status {
                case .success:
                    DispatchQueue.main.async {
                        coordinator.openConfirmPhoneScreen(phoneNumber: self.phoneField.text ?? "")
                    }
                case .no_channels:
                    coordinator.showErrorAlert(with: NSLocalizedString("phoneError", comment: ""))
                case .invalid_client:
                    coordinator.showErrorAlert(with: NSLocalizedString("clientIdError", comment: ""))
                case .require_code_challenge:
                    coordinator.showErrorAlert(with: NSLocalizedString("codeChalengeError", comment: ""))
                case .invalid_email:
                    coordinator.showErrorAlert(with: NSLocalizedString("emailError", comment: ""))
                case .invalid_phone:
                    coordinator.showErrorAlert(with: NSLocalizedString("phoneError", comment: ""))
                case .request_timeout_limit:
                    coordinator.showErrorAlert(with: NSLocalizedString("requestTimeoutLimit", comment: ""))
                case .sent_notification_fail:
                    coordinator.showErrorAlert(with: NSLocalizedString("sentNotificationFail", comment: ""))
                case .server_error:
                    coordinator.showErrorAlert(with: NSLocalizedString("sentNotificationFail", comment: ""))
                case .undefined(error: let error):
                    coordinator.showErrorAlert(with: error)
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(phoneField)
        view.addSubview(divider)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(-30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        phoneField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(phoneField.snp.bottom).offset(2)
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
    }
}

extension PhoneAuthViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text as NSString? else { return true }
        let newText = text.replacingCharacters(in: range, with: string)
        
        let maskTextField = textField as! JMMaskTextField
        guard let unmaskedText = maskTextField.stringMask?.unmask(string: newText) else { return true }
        
        if unmaskedText.count >= 11 {
            maskTextField.maskString = "+0 (000) 000-00-00"
        } else {
            maskTextField.maskString = "+0 (000) 000-00-00"
        }
        
        guard let viewModel = self.viewModel else {
            return true
        }
        
        viewModel.input.phoneNumber.onNext(unmaskedText)
        
        return true
    }
    
}
