//
//  ProfileViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/19/21.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileViewController: UIViewController {

    var viewModel: ProfileViewModelProtocol!
    var disposeBag = DisposeBag()
    //MARK: interface elements variables
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var middleNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var lastNameTitle: UILabel!
    @IBOutlet weak var firstNameTitle: UILabel!
    @IBOutlet weak var middleNameTitle: UILabel!
    @IBOutlet weak var emailTitle: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.setupLayout()
        self.localize()
    }
    
    private func localize() {
        lastNameTitle.text = NSLocalizedString("lastNameTitle", comment: "")
        firstNameTitle.text = NSLocalizedString("firstNameTitle", comment: "")
        middleNameTitle.text = NSLocalizedString("middleNameTitle", comment: "")
        emailTitle.text = NSLocalizedString("emailTitle", comment: "")
        exitButton.setTitle(NSLocalizedString("exitAccountButtonTitle", comment: ""), for: .normal)
    }
    
    private func setupLayout() {
        self.profileImage.layer.cornerRadius = 100
        self.viewModel.getUserData().bind { profile in
            self.firstNameLabel.text = profile.firstName == "" ? " " : profile.firstName
            self.lastNameLabel.text = profile.lastName == "" ? " " : profile.lastName
            self.middleNameLabel.text = profile.middleName == "" ? " " : profile.middleName
            self.emailLabel.text = profile.email
            self.profileImage.image = UIImage(data: profile.userPic!)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func exitAccount(_ sender: Any) {
        self.viewModel.exitAccount()
    }
    
}
