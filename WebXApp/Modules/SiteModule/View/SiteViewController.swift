//
//  SiteViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

class SiteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Сайт"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(openSetupList))
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
    
    @objc func openSetupList() {
        
    }

}
