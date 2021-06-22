//
//  InstallWebasystViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 17.06.2021.
//

import UIKit

class InstallWebasystViewController: UIViewController {

    var viewModel: InstallWebasystViewModelProtocol!
    
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
        
    }
    
}
