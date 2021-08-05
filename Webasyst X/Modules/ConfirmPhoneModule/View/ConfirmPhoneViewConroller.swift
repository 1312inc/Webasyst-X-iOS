//
//  ConfirmPhone module - ConfirmPhoneViewConroller.swift
//  Teamwork
//
//  Created by viktkobst on 21/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ConfirmPhoneViewController: UIViewController {

    //MARK: ViewModel property
    var viewModel: ConfirmPhoneViewModel?
    var coordinator: ConfirmPhoneCoordinator?
    
    private var disposeBag = DisposeBag()
    private var secondsTimer: Int = 0
    
    private let iconImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "confirmCode")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("titleConfirmCode", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "\(NSLocalizedString("descriptionPhone", comment: "")) \n\(viewModel?.phoneNumber ?? "")"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmCodeField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.textContentType = .oneTimeCode
        textField.textAlignment = .center
        textField.delegate = self
        textField.placeholder = NSLocalizedString("titleConfirmCode", comment: "")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let resendCodeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("resendCodeLabel", comment: "")
        label.textAlignment = .center
        label.textColor = UIColor.systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("resendCodeButton", comment: ""), for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let codeSendIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let codeSendLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("codeSendLabel", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.systemGreen
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("nextButton", comment: ""), for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        return button
    }()
    
    private var resendCodeTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.bindableViewModel()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextButton)
        confirmCodeField.becomeFirstResponder()
    }
    
    private func bindableViewModel() {
        guard let viewModel = self.viewModel else { return }
        guard let coordinator = self.coordinator else { return }
        
        viewModel.output.resendButtonEnabled
            .subscribe(onNext: { [weak self] enabled in
                guard let self = self else { return }
                if enabled {
                    DispatchQueue.main.async {
                        self.secondsTimer = 0
                        self.resendButton.isHidden = false
                        self.resendCodeLabel.isHidden = false
                        self.codeSendLabel.isHidden = true
                        self.codeSendIcon.isHidden = true
                        self.timerLabel.isHidden = true
                        if self.resendCodeTimer?.isValid ?? true {
                            self.resendCodeTimer?.invalidate()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.resendButton.isHidden = true
                        self.resendCodeLabel.isHidden = true
                        self.codeSendLabel.isHidden = false
                        self.codeSendIcon.isHidden = false
                        self.timerLabel.isHidden = false
                        self.resendCodeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.editTimerLabel), userInfo: nil, repeats: true)
                    }
                }
            }).disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(to: viewModel.input.submitButtonTap)
            .disposed(by: disposeBag)
        
        resendButton.rx.tap
            .bind(to: viewModel.input.resendButtonTap)
            .disposed(by: disposeBag)
        
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
        
        viewModel.output.resendCodeStatus
            .subscribe(onNext: { status in
                switch status {
                case .success:
                    print("success")
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
        
        viewModel.output.serverStatus
            .subscribe(onNext: { status in
                switch status {
                case .success:
                    coordinator.successAuth()
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
        view.backgroundColor = UIColor(named: "backgroundColor")
        view.addSubview(iconImage)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(confirmCodeField)
        view.addSubview(divider)
        view.addSubview(resendCodeLabel)
        view.addSubview(resendButton)
        view.addSubview(codeSendIcon)
        view.addSubview(codeSendLabel)
        view.addSubview(timerLabel)
        
        iconImage.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(-30)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImage.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        confirmCodeField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(confirmCodeField.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(1)
        }
        
        resendCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        resendButton.snp.makeConstraints { make in
            make.top.equalTo(resendCodeLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        codeSendLabel.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        codeSendIcon.snp.makeConstraints { make in
            make.right.equalTo(codeSendLabel).offset(-10)
            make.centerY.equalTo(codeSendLabel)
            make.width.equalTo(15)
            make.height.equalTo(15)
        }
        
        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(resendCodeLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
    }
    
    @objc private func editTimerLabel() {
        self.secondsTimer += 1
        self.timerLabel.text = "\(NSLocalizedString("timerText", comment: "")) \(90 - self.secondsTimer) \(NSLocalizedString("seconds", comment: ""))"
    }

}

extension ConfirmPhoneViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var confirmCode = (textField.text ?? "") + string
        
        if range.length == 1 {
            let maxIndex = confirmCode.index(confirmCode.startIndex, offsetBy: confirmCode.count - 1)
            confirmCode = String(confirmCode[confirmCode.startIndex ..< maxIndex])
        }
        
        if confirmCode.count >= 6 {
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = UIColor.systemBlue
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = UIColor.systemGray
        }
        
        if string.count >= 6 && string.count <= 20, let viewModel = self.viewModel {
            viewModel.input.verificationCode.onNext(confirmCode)
        }
        
        confirmCodeField.text = confirmCode
        
        guard let viewModel = self.viewModel else { return false }
        viewModel.input.verificationCode.onNext(confirmCode)
        
        return false
    }
}
