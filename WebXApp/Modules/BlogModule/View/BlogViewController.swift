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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(openSetupList))
        view.backgroundColor = .systemBackground
    }
    
    @objc func openSetupList() {
        self.viewModel.openInstallList()
    }

}
