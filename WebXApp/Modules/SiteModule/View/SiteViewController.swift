//
//  SiteViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import Webasyst

class SiteViewController: UIViewController {

    var webasyst = WebasystApp()
    var viewModel: SiteViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("siteTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        self.createLeftNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateData), name: Notification.Name("ChangedSelectDomain"), object: nil)
    }
    
    private func createLeftNavigationBar() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        
        guard let changeInstall = self.webasyst.getUserInstall(selectDomain) else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.triangle"), style: .done, target: self, action: #selector(openSetupList))
            return
        }
        
        let imageView = UIImageView(image: UIImage(data: changeInstall.image!))
        imageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        imageView.contentMode = .scaleAspectFill
        let textImage = changeInstall.logoText
        
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight(600))
        textLabel.text = textImage
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        
        imageView.center = view.center
        textLabel.center = view.center
        
        imageView.layer.cornerRadius = view.frame.height / 2
        imageView.layer.masksToBounds = true
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(self.openSetupList), for: .touchDown)
        button.center = view.center
        
        view.addSubview(imageView)
        view.addSubview(textLabel)
        view.addSubview(button)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    @objc func updateData() {
        self.createLeftNavigationBar()
    }
    
    @objc func openSetupList() {
        self.viewModel.openInstallList()
    }

}
