//
//  ShopViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit

class ShopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Магазин"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.triangle"), style: .done, target: self, action: #selector(openSetupList))
        view.backgroundColor = .systemBackground
    }
    
    @objc func openSetupList() {
        
    }
}