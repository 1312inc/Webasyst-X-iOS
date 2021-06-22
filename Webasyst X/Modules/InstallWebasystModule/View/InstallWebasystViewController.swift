//
//  InstallWebasystViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 17.06.2021.
//

import UIKit
import RxSwift
import RxCocoa

class InstallWebasystViewController: UIViewController {

    var viewModel: InstallWebasystViewModelProtocol!
    var disposeBag = DisposeBag()
    
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
        self.viewModel.buttonEnabled
            .subscribe(onNext: { enabled in
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
        self.viewModel.openInstruction()
    }
    
    @IBAction func createNewAccountTap(_ sender: Any) {
        self.viewModel.createNewWebasyst()
    }
    
}
