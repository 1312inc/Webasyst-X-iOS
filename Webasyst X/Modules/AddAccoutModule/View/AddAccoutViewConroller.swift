//
//  AddAccout module - AddAccoutViewConroller.swift
//  Teamwork
//
//  Created by viktkobst on 22/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AddAccoutViewController: UIViewController {

    //MARK: ViewModel property
    var viewModel: AddAccoutViewModel?
    var coordinator: AddAccoutCoordinator?
    
    private var disposeBag = DisposeBag()
    
    //MARK: Interface elements property
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var anInstallLabel: UILabel!
    @IBOutlet weak var anInstallDescriptionLabel: UILabel!
    @IBOutlet weak var aboutConnectButton: UIButton!
    @IBOutlet weak var createInstallLabel: UILabel!
    @IBOutlet weak var createInstallDescriptionLabel: UILabel!
    @IBOutlet weak var createInstallButton: UIButton!
    @IBOutlet weak var trialPeriodLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = UIColor(named: "backgroundColor")
        self.setupLayout()
        self.localized()
        self.bindableViewModel()
    }
    
    private func bindableViewModel() {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.output.newAccountButtonEnabled
            .subscribe(onNext: { [weak self] enabled in
                guard let self = self else { return }
                if enabled {
                    DispatchQueue.main.async {
                        self.createInstallLabel.isUserInteractionEnabled = true
                        self.createInstallButton.backgroundColor = UIColor.systemOrange
                    }
                } else {
                    DispatchQueue.main.async {
                        self.createInstallLabel.isUserInteractionEnabled = false
                        self.createInstallButton.backgroundColor = UIColor.systemGray
                    }
                }
            }).disposed(by: self.disposeBag)
        
        viewModel.output.createAccountResult
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                guard let coordinator = self.coordinator else { return }
                
                switch result {
                case .success(let url):
                    let localizedString = NSLocalizedString("successNewInstall", comment: "")
                    let replacedString = String(format: localizedString, url)
                    coordinator.showAlert(title: NSLocalizedString("successTitle", comment: ""), message: replacedString)
                case .error:
                    coordinator.showAlert(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("errorCreateNewInstall", comment: ""))
                }
                
            }).disposed(by: disposeBag)
        
        self.createInstallButton.rx.tap
            .bind(to: viewModel.input.createNewAccountTap)
            .disposed(by: disposeBag)
    }
    
    private func setupLayout() {
        createInstallButton.layer.cornerRadius = 10
    }
    
    private func localized() {
        titleLabel.text = NSLocalizedString("addInstallTitle", comment: "")
        anInstallLabel.text = NSLocalizedString("anInstallTitle", comment: "")
        anInstallDescriptionLabel.text = NSLocalizedString("anInstallDescription", comment: "")
        aboutConnectButton.setTitle(NSLocalizedString("aboutConnectButton", comment: ""), for: .normal)
        createInstallLabel.text = NSLocalizedString("createInstallTitle", comment: "")
        createInstallDescriptionLabel.text = NSLocalizedString("createInstallDescription", comment: "")
        createInstallButton.setTitle(NSLocalizedString("createInstallButton", comment: ""), for: .normal)
        trialPeriodLabel.text = NSLocalizedString("freeTrialLabel", comment: "")
    }
    
    @IBAction func aboutInConnection(_ sender: Any) {
        self.openAboutInConnection()
    }
    
    //MARK: Navigation methods
    private func openAboutInConnection() {
        guard let coordinator = self.coordinator else { return }
        coordinator.openInstructionWaid()
    }

}
