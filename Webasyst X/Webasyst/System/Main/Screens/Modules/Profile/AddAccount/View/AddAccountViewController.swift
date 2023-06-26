//
//  AddAccountViewController.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import Webasyst

final class AddAccountViewController: UIViewController {
    
    private enum CancelType {
        case qrCode
        case digitalCode
        case createAccount
    }
    
    //MARK: ViewModel property
    var viewModel: AddAccountViewModel
    var coordinator: AddAccountCoordinator
    fileprivate var activityIndicator = UIActivityIndicatorView(style: .medium)
    fileprivate var disposeBag = DisposeBag()
    let webasyst = WebasystApp()
    fileprivate var bottomBlock: Bool
    public var completion: (() -> ())?
    
    init(viewModel: AddAccountViewModel,
         coordinator: AddAccountCoordinator,
         bottomBlock: Bool) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.bottomBlock = bottomBlock
        super.init(nibName: nil, bundle: nil)
        bindableViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Interface elements property
    
    func view() -> AddAccountView {
        view as! AddAccountView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view().configure(email: webasyst.getProfileData()?.email)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layout()
    }
    
    override func loadView() {
        view = AddAccountView(bottomBlock: bottomBlock)
    }
    
    private func bindableViewModel() {
        
        viewModel.output.qrCodeConnectAccountResult
            .observeOn(MainScheduler.asyncInstance)
            .share()
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let accountName):
                    if let completion = self.completion {
                        
                        let successBlock = {
                            self.activityIndicator.stopAnimating()
                            WebasystApp.requestFullScreenConfetti(for: self)
                            self.showAlert(withTitle: .getLocalizedString(withKey: "success"),
                                           description: .getLocalizedString(withKey: "connectAccountSuccessBody").replacingOccurrences(of: "%ACCOUNTNAME%", with: accountName ?? "unowned profile"),
                                           okCompletionBlock: {
                                completion()
                                self.navigationController?.dismiss(animated: true, completion: {
                                    self.createLeftNavigationButton()
                                    NotificationCenter.default.post(name: Service.Notify.update, object: nil)
                                })
                            })
                        }
                        
                        if let presentedViewController = self.navigationController?.presentedViewController {
                            presentedViewController.dismiss(animated: true, completion: {
                                successBlock()
                            })
                        } else {
                            successBlock()
                        }
                        
                    }
                case .error(let description):
                    self.cancel(.qrCode, alertDescription: .getLocalizedString(withKey: "connectWebasystAccountError"), alertMessage: description)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.digitalCodeConnectAccountResult
            .observeOn(MainScheduler.asyncInstance)
            .share()
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let accountName):
                    if let completion = self.completion {
                        self.activityIndicator.stopAnimating()
                        WebasystApp.requestFullScreenConfetti(for: self)
                        self.showAlert(withTitle: .getLocalizedString(withKey: "success"),
                                       description: .getLocalizedString(withKey: "connectAccountSuccessBody").replacingOccurrences(of: "%ACCOUNTNAME%", with: accountName ?? "unowned profile"),
                                       errorMessage: nil,
                                       tryAgainBlock: false) {
                            completion()
                            self.navigationController?.dismiss(animated: true, completion: {
                                self.createLeftNavigationButton()
                                NotificationCenter.default.post(name: Service.Notify.update, object: nil)
                            })
                        }
                        self.view().topLayerOfCodeStackView.isUserInteractionEnabled = true
                    }
                case .error(let description):
                    self.cancel(.digitalCode, alertDescription: .getLocalizedString(withKey: "connectWebasystAccountError"), alertMessage: description)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.createAccountResult
            .share()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let renameError):
                    if let completion = self.completion {
                        self.activityIndicator.stopAnimating()
                        WebasystApp.requestFullScreenConfetti(for: self)
                        let description: String = renameError == nil ? .getLocalizedString(withKey: "addAccountSuccessBody") : .getLocalizedString(withKey: "addAccountSuccessButNotRenamedBody")
                        self.showAlert(withTitle: .getLocalizedString(withKey: "success"),
                                       description: description,
                                       errorMessage: renameError,
                                       tryAgainBlock: false) {
                            completion()
                            self.navigationController?.dismiss(animated: true, completion: {
                                self.createLeftNavigationButton()
                                NotificationCenter.default.post(name: Service.Notify.update, object: nil)
                            })
                        }
                        self.view().newShopButton.isUserInteractionEnabled = true
                    }
                case .error(let description):
                    self.cancel(.createAccount, alertDescription: .getLocalizedString(withKey: "errorCreateNewInstall"), alertMessage: description)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.input.digitalCode
            .observeOn(MainScheduler.asyncInstance)
            .share()
            .skip(1)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                if case .start = self.coordinator.type {
                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                } else {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                }
                self.activityIndicator.startAnimating()
                self.view().topLayerOfCodeStackView.isUserInteractionEnabled = false
            })
            .subscribe(onNext: { [weak self] digitalCode in
                guard let self = self else { return }
                self.viewModel.input.sendDigitalCode.onNext(digitalCode)
            })
            .disposed(by: disposeBag)
        
        view().newShopButton.rx.tap
            .observeOn(MainScheduler.asyncInstance)
            .share()
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                if case .start = self.coordinator.type {
                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                } else {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                }
                self.view().endEditing(true)
                self.view().newShopButton.backgroundColor = .systemGray3
                self.activityIndicator.startAnimating()
                self.view().newShopButton.isUserInteractionEnabled = false
            })
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if let shopDomain = self.view().newShopNameLabel.text?.components(separatedBy: ".").first {
                    let newShop = NewShopModel(domain: shopDomain, name: self.view().newShopNameTextField.text)
                    self.viewModel.input.createNewAccountTap.onNext(newShop)
                } else {
                    self.cancel(.createAccount, alertDescription: .getLocalizedString(withKey: "shopNameErrorDescription"))
                }
            })
            .disposed(by: disposeBag)
                
        view().loginQRButton.rx.tap
            .observeOn(MainScheduler.asyncInstance)
            .share()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.coordinator.openQRController { [weak self] code in
                    guard let self = self else { return }
//                    self.navigationController?.dismiss(animated: true)
                    if case .start = self.coordinator.type {
                        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                    } else {
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                    }
                    self.activityIndicator.startAnimating()
                    self.viewModel.input.sendQRCode.onNext(code)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension AddAccountViewController {
    
    private func cancel(_ type: CancelType, alertDescription: String, alertMessage: String? = nil) {
        
        activityIndicator.stopAnimating()
        self.showAlert(withTitle: .getLocalizedString(withKey: "errorTitle"),
                       description: alertDescription, errorMessage: alertMessage, analytics: AnalyticsModel(type: "waid", debugInfo: debug(), method: "addAccount"))
        
        switch type {
        case .createAccount:
            view().newShopButton.backgroundColor = .appColor
            view().newShopButton.isUserInteractionEnabled = true
        case .digitalCode:
            view().clearCodeTF()
            view().topLayerOfCodeStackView.isUserInteractionEnabled = true
        case .qrCode:
            break
        }
    }
    
    fileprivate func layout() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.appearanceColor(color: .reverseLabel)
        view.insetsLayoutMarginsFromSafeArea = false
    }
}
