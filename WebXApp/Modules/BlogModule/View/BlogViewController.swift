//
//  BlogViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

class BlogViewController: UIViewController {

    var viewModel: BlogViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Блог"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.triangle"), style: .done, target: self, action: #selector(openSetupList))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .done, target: self, action: #selector(openUserProfile))
    }
    
    @objc func openSetupList() {
        self.viewModel.openInstallList()
    }
    
    @objc func openUserProfile() {
        self.viewModel.openProfileScreen()
    }

}
