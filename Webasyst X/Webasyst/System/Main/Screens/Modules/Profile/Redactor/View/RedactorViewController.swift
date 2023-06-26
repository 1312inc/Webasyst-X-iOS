//
//  RedactorViewController.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 18.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import Webasyst

final class RedactorViewController: UIViewController {
    
    //MARK: ViewModel property
    let laterNeeded: Bool
    var viewModel: RedactorViewModel?
    var coordinator: RedactorCoordinator?
    weak var delegate: PassImageToPreviousController?
    private var disposeBag = DisposeBag()
    private var activityIndicator = UIActivityIndicatorView()
    private var sucessfullyUpdatedBind: Disposable?
    
    var window: UIWindow? {
        UIApplication.shared.keyWindow
    }
    
    //MARK: Interface elements property
    
    override func loadView() {
        view = RedactorView(frame: .zero, laterNeeded: laterNeeded)
    }
    
    func view() -> RedactorView {
        view as! RedactorView
    }
    
    init(image: UIImage?,profile: ProfileData?, laterNeeded: Bool) {
        self.laterNeeded = laterNeeded
        super.init(nibName: nil, bundle: nil)
        view().setDefaults(profile)
        view().imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view().delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view().addGestureRecognizer(gesture)
        addLoader()
        navigationController?.navigationBar.tintColor = .appColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if sucessfullyUpdatedBind == nil {
            bindableViewModel()
        }
        navigationController?.appearanceColor(color: .backgroundColor)
        view().layoutIfNeeded()
    }
    
    //MARK: Bindable ViewModel
    private func bindableViewModel() {
        
        if let viewModel = viewModel {
            
            sucessfullyUpdatedBind = viewModel.output.sucessfullyUpdated
                .share()
                .observeOn(MainScheduler.asyncInstance)
                .subscribe { [weak self] in
                    guard let self = self else { return }
                    switch $0.element {
                    case .success(let element):
                        switch element {
                        case .image(let image):
                            self.view().imageView.image = image
                            self.delegate?.update(image)
                            self.view().updateProfileImage(image)
                        case .remove:
                            let image = UIImage(named: "no-avatar")
                            self.view().imageView.image = image
                            self.delegate?.update(image)
                        case .profile:
                            self.later()
                        case .delete(let bool):
                            if let bool = bool {
                                self.coordinator?.showAlert(standard: false, success: bool)
                            }
                        }
                        if case .delete = element {} else {
                            if !self.laterNeeded {
                                self.navigationController?.popViewController(animated: true)
//                                self.navigationController?.dismiss(animated: true)
                                NotificationCenter.default.post(name: Service.Notify.navigationBar, object: nil)
                            }
                        }
                        self.view().endLoading()
                    case .failure(let error):
                        self.coordinator?.confirmAlertUpdatedShow(.failure(error))
                        self.view().endLoading()
                    case .none:
                        break
                    }
                    self.view().saveButton.backgroundColor = .appColor
                    self.activityIndicator.stopAnimating()
                    self.window?.isUserInteractionEnabled = true
                }
            sucessfullyUpdatedBind?.disposed(by: disposeBag)
            
            viewModel.output.userProfileData
                .observeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] profile in
                    guard let self = self else { return }
                    self.view().setDefaults(profile)
                }).disposed(by: disposeBag)
            
        }
        if laterNeeded {
            viewModel?.getUserData()
        }
        
    }
    
}

extension RedactorViewController: RedactorInteractive {
    
    func later() {
        if let completion = coordinator?.completion {
            completion()
        }
    }
    
    func save(_ profile: ProfileData) {
        view().saveButton.backgroundColor = .systemGray3
        viewModel?.input.updateNeeded.accept(.profile(profile))
        activityIndicator.startAnimating()
        window?.isUserInteractionEnabled = false
    }
    
    func remove() {
        view().saveButton.backgroundColor = .systemGray3
        viewModel?.input.updateNeeded.accept(.remove)
        view().startLoading()
        window?.isUserInteractionEnabled = false
    }
    
    func newImage() {
        coordinator?.startImageSelector(self, completion: { [weak self] image in
            guard let self = self else { return }
            self.view().saveButton.backgroundColor = .systemGray3
            self.window?.isUserInteractionEnabled = false
            self.view().startLoading()
            self.viewModel?.input.updateNeeded.accept(.image(image))
        })
    }
    
    func delete() {
        coordinator?.showAlert()
    }
    
}

extension RedactorViewController: DeleteDelegate {
    
    func deleteFromAlert() {
        viewModel?.input.updateNeeded.accept(.delete(nil))
    }
    
}

extension RedactorViewController {
    
    func addLoader() {
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(barButton, animated: true)
    }
    
    @objc private func hideKeyboard() {
        view().endEditing(true)
    }
}
