//
//  ProfileViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/19/21.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Профиль"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

}
