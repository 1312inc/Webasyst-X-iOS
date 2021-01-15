//
//  VeniViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/14/21.
//

import UIKit

class VeniViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let userName = UserDefaults.standard.string(forKey: "userName")
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")
        self.title = "Привет"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        textLabel.text = "Автризация пользователя \(userName ?? "") c email: \(userEmail ?? "") прошла успешно"
    }

}
