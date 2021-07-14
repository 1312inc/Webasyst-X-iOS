//
//  ConfirmCodeViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 10.06.2021.
//

import UIKit
import RxSwift
import RxCocoa

class ConfirmCodeViewController: UIViewController {

    var viewModel: ConfirmCodeViewModelProtocol!
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
        label.text = "\(NSLocalizedString("descriptionPhone", comment: "")) \n\(viewModel.phoneNumber)"
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
        button.addTarget(self, action: #selector(resendCode), for: .touchDown)
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
    
    private var resendCodeTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor")
        confirmCodeField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("nextButton", comment: ""), style: .plain, target: self, action: #selector(tappedNext))
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = UIColor.systemGray
        self.setupLayout()
        self.bindableViewModel()
    }
    
    private func bindableViewModel() {
        self.viewModel.enabledTimerSubject
            .subscribe(onNext: { enabledTimer in
                if enabledTimer {
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
        
        self.viewModel.enabledButtonSubject
            .subscribe(onNext: { enabled in
                if enabled {
                    DispatchQueue.main.async {
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("nextButton", comment: ""), style: .plain, target: self, action: #selector(self.tappedNext))
                    }
                } else {
                    DispatchQueue.main.async {
                        let uiBusy = UIActivityIndicatorView()
                        uiBusy.hidesWhenStopped = true
                        uiBusy.startAnimating()
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
                    }
                }
            }).disposed(by: disposeBag)
        
        confirmCodeField.rx.controlEvent(.editingChanged)
            .subscribe(onNext: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    if self.confirmCodeField.text?.count ?? 0 >= 6 && self.confirmCodeField.text?.count ?? 0 <= 20 {
                        print("больше 6")
                        self.viewModel.sendCode(with: self.confirmCodeField.text ?? "")
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupLayout() {
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
        NSLayoutConstraint.activate([
            iconImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            iconImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 100),
            iconImage.heightAnchor.constraint(equalToConstant: 100),
            titleLabel.topAnchor.constraint(equalTo: iconImage.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            confirmCodeField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            confirmCodeField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmCodeField.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            divider.topAnchor.constraint(equalTo: confirmCodeField.bottomAnchor, constant: 2),
            divider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            divider.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            divider.heightAnchor.constraint(equalToConstant: 1),
            resendCodeLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 30),
            resendCodeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resendCodeLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            resendButton.topAnchor.constraint(equalTo: resendCodeLabel.bottomAnchor, constant: 10),
            resendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resendButton.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            codeSendLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 30),
            codeSendLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            codeSendIcon.centerYAnchor.constraint(equalTo: codeSendLabel.centerYAnchor),
            codeSendIcon.widthAnchor.constraint(equalToConstant: 15),
            codeSendIcon.heightAnchor.constraint(equalToConstant: 15),
            codeSendIcon.trailingAnchor.constraint(equalTo: codeSendLabel.leadingAnchor, constant: -10),
            timerLabel.topAnchor.constraint(equalTo: resendCodeLabel.bottomAnchor, constant: 10),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
        ])
    }
    
    @objc private func tappedNext() {
        self.viewModel.sendCode(with: confirmCodeField.text ?? "")
    }
    
    @objc private func resendCode() {
        self.viewModel.resendCode()
    }
    
    @objc private func editTimerLabel() {
        self.secondsTimer += 1
        self.timerLabel.text = "\(NSLocalizedString("timerText", comment: "")) \(90 - self.secondsTimer) \(NSLocalizedString("seconds", comment: ""))"
    }
    
}

extension ConfirmCodeViewController: UITextFieldDelegate {
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
        
        if string.count >= 6 && string.count <= 20 {
            self.viewModel.sendCode(with: confirmCode)
        }
        
        confirmCodeField.text = confirmCode
        
        return false
    }
}
