//
//  ConfirmPhoneViewController.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 03.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ConfirmPhoneViewController: UIViewController, UIDeviceShared {

    //MARK: ViewModel property
    var viewModel: ConfirmPhoneViewModel?
    var coordinator: ConfirmPhoneCoordinator?
    
    private var disposeBag = DisposeBag()
    private var secondsTimer: Int = 0
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(frame: .init(x: 0, y: 0, width: 20, height: 20))
        return activityIndicatorView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = .getLocalizedString(withKey: "titleConfirmCode")
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = .getLocalizedString(withKey: "descriptionPhone")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resendCodeLabel: UILabel = {
        let label = UILabel()
        label.text = .getLocalizedString(withKey: "resendCodeLabel")
        label.textAlignment = .center
        label.textColor = UIColor.systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = isDark ? .systemGray4 : .systemGray6
        textField.font = .systemFont(ofSize: 22, weight: .bold)
        textField.layer.masksToBounds = true
        textField.keyboardType = .numberPad
        textField.layer.cornerRadius = 10
        textField.delegate = self
        textField.contentHorizontalAlignment = .center
        textField.textAlignment = .center
        textField.defaultTextAttributes.updateValue(4, forKey: NSAttributedString.Key.kern)
        textField.tintColor = .appColor
        return textField
    }()

    private let resendButton: UIButton = {
        let button = UIButton()
        button.setTitle(.getLocalizedString(withKey: "resendCodeButton"), for: .normal)
        button.setTitleColor(.appColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.text = viewModel?.phoneNumber
        return label
    }()

    private let codeSendLabel: UILabel = {
        let label = UILabel()
        label.text = .getLocalizedString(withKey: "codeSendLabel")
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.systemGreen
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "\(String.getLocalizedString(withKey: "timerText")) 90 \(String.getLocalizedString(withKey: "seconds"))"
        label.textColor = UIColor.systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var resendCodeTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.bindableViewModel()
        textField.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        view.addGestureRecognizer(tap)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }

    private func bindableViewModel() {
        guard let viewModel = viewModel else { return }

        viewModel.output.resendButtonEnabled
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] enabled in
                guard let self = self else { return }
                self.secondsTimer = 0
                self.editTimerLabel()
                self.resendCodeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
                    self?.editTimerLabel()
                })
            }).disposed(by: disposeBag)

        resendButton.rx.tap
            .takeUntil(rx.deallocated)
            .bind(to: viewModel.input.resendButtonTap)
            .disposed(by: disposeBag)

        viewModel.output.resendCodeStatus
            .subscribe(onNext: { [weak self] status in
                guard let self = self, let coordinator = coordinator else { return }
                switch status {
                case .success:
                    print("success")
                case .no_channels:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "phoneError"))
                case .invalid_client:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "clientIdError"))
                case .require_code_challenge:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "codeChalengeError"))
                case .invalid_email:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "emailError"))
                case .invalid_phone:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "phoneError"))
                case .request_timeout_limit:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "requestTimeoutLimit"))
                case .sent_notification_fail:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "sentNotificationFail"))
                case .server_error:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "sentNotificationFail"))
                case .undefined(error: let error):
                    coordinator.showErrorAlert(with: error)
                }
            }).disposed(by: disposeBag)

        viewModel.output.serverStatus
            .subscribe(onNext: { [weak self] status in
                guard let self = self, let coordinator = coordinator else { return }

                let completion = { [weak self] in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        if status != .success {
                            self.textField.isUserInteractionEnabled = true
                        }
                        self.activityIndicator.stopAnimating()
                    }
                }

                switch status {
                case .success:
                    coordinator.successAuth(completion)
                case .no_channels:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "phoneError"))
                case .invalid_client:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "clientIdError"))
                case .require_code_challenge:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "codeChalengeError"))
                case .invalid_email:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "emailError"))
                case .invalid_phone:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "phoneError"))
                case .request_timeout_limit:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "requestTimeoutLimit"))
                case .sent_notification_fail:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "sentNotificationFail"))
                case .server_error:
                    coordinator.showErrorAlert(with: .getLocalizedString(withKey: "sentNotificationFail"))
                case .undefined(error: let error):
                    coordinator.showErrorAlert(with: error)
                }

                switch status {
                case .success:
                    break
                default:
                    completion()
                }

            }).disposed(by: disposeBag)
    }

    private func setupLayout() {
        view.backgroundColor = .reverseLabel
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(phoneLabel)
        view.addSubview(textField)
        view.addSubview(resendButton)
        view.addSubview(timerLabel)

        timerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
            make.height.equalTo(100)
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(self.phoneLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(70)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(60)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }

        resendButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
            make.height.equalTo(25)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
        }

        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }

    }

    @objc private func hide() {
        view.endEditing(true)
    }

    @objc private func editTimerLabel() {
        let text = "\(String.getLocalizedString(withKey: "timerText")) \(90 - self.secondsTimer) \(String.getLocalizedString(withKey: "seconds"))"
        if secondsTimer <= 90 {
            timerLabel.isHidden = false
            resendButton.isHidden = true
            secondsTimer += 1
        } else {
            resendCodeTimer?.invalidate()
            secondsTimer = 0
            timerLabel.isHidden = true
            resendButton.isHidden = false
        }
        self.timerLabel.text = text
    }

}

extension ConfirmPhoneViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var confirmCode = (textField.text ?? "") + string

        if range.length == 1 {
            let maxIndex = confirmCode.index(confirmCode.startIndex, offsetBy: confirmCode.count - 1)
            confirmCode = String(confirmCode[confirmCode.startIndex ..< maxIndex])
        }
        if confirmCode.count == 6 && range.length == .zero {
            hide()
            textField.text = confirmCode
            viewModel?.input.verificationCode.onNext(confirmCode)
            activityIndicator.startAnimating()
            textField.isUserInteractionEnabled = false
        }
        return confirmCode.count < 7
    }

}
