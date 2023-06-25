//
//  AuthViewController.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 03.10.2022.
//

import UIKit
import RxSwift

final class AuthViewController: UIViewController {
    
    //MARK: ViewModel property
    var viewModel: AuthViewModel
    var coordinator: AuthCoordinator
    private var disposeBag = DisposeBag()
    
    init(coordinator: AuthCoordinator, viewModel: AuthViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func view() -> AuthSlide {
        return view as! AuthSlide
    }
    
    //MARK: Interface elements property
    
    override func loadView() {
        view = AuthSlide()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view().delegate = self
        view().type = coordinator.type
        view().textField.delegate = self
        bindableViewModel()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.searchController = nil
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.appearanceColor(color: .reverseLabel)
        navigationController?.navigationBar.scrollEdgeAppearance = .none
        navigationController?.navigationBar.tintColor = .appColor
        navigationController?.tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        UserDefaults.setCurrentInstall(withValue: nil)
    }
    
    // MARK: - Bindable ViewModel
    private func bindableViewModel() {
        checkNext()

        viewModel.output.dataSourceDriver.drive { [weak self] in
            let array = $0.keys.compactMap { String($0) }.sorted()
            self?.view().setUpDataSource(data: array)
        }.disposed(by: disposeBag)

        viewModel.output.phoneCode.drive { [weak self] in
            self?.view().setCode($0)
        }.disposed(by: disposeBag)

    }

    @objc private func hide() {
        view.endEditing(true)
    }
    
}

// MARK: - Extensions

extension AuthViewController: AuthViewDelegate {

    func select(name: String) {
        viewModel.input.country.accept(name)
    }

    func openDemoViewController() {
        coordinator.openDemoViewController()
    }

    func phoneLogin() {
        guard let text = view().textField.text else { return }
        viewModel.input.send.accept(text)
        view().interactiveController(false)
        hide()
    }
    
    func appleIDLogin() {
        coordinator.appleIDLogin(vc: self)
    }

    func webasystIDLogin() {
        coordinator.webasystIDLogin()
    }
    
    func QRLogin() {
        coordinator.QRLogin()
    }

}

extension AuthViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        let newCountry = viewModel.getCountryCode(text + string)
        textField.text = "+\(text.dropFirst())"
        
        if !newCountry.isEmpty, newCountry != viewModel.countryForParsing {
            let countryName = viewModel.countryName(countryCode: newCountry)
            view().setTitle(countryName)
            viewModel.input.country.accept(countryName)
        }
        
        if range.length == .zero && !newCountry.isEmpty {
            let phone = viewModel.extractPhone(text + string)
            textField.text = phone
            let valid = viewModel.validator(phone)
            view().backgroundColor(canNext: valid)
            return false
        } else {
            view().backgroundColor(canNext: false)
            return true
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
    }
}

extension AuthViewController {

    func checkNext() {
        viewModel.output.serverStatus
                .drive(onNext: { [weak self] status in
                    guard let self = self else { return }
                    guard let text = view().textField.text else { return }
                    switch status {
                    case .success:
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.coordinator.openPhoneLogin(self, phone: text)
                        }
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
                    view().interactiveController(true)
                }).disposed(by: disposeBag)
    }

}
