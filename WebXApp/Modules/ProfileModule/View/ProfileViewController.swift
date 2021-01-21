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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.setupLayout()
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
