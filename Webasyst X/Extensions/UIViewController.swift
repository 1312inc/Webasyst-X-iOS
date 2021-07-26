//
//  UIViewController.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 05.07.2021.
//

import UIKit
import Webasyst
import SnapKit

extension UIViewController {
    
    internal func createLeftNavigationButton(action: Selector) {
        let webasyst = WebasystApp()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        
        guard let changeInstall = webasyst.getUserInstall(selectDomain) else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.triangle"), style: .done, target: self, action: action)
            return
        }
        
        let imageView = UIImageView(image: UIImage(data: changeInstall.image!))
        imageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        imageView.contentMode = .scaleAspectFill
        let textImage = changeInstall.logoText
        
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        textLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight(600))
        textLabel.text = textImage
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        
        imageView.center = view.center
        textLabel.center = view.center
        
        imageView.layer.cornerRadius = view.frame.height / 2
        imageView.layer.masksToBounds = true
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        button.setTitle("", for: .normal)
        button.addTarget(self, action: action, for: .touchDown)
        button.center = view.center
        
        view.addSubview(imageView)
        view.addSubview(textLabel)
        view.addSubview(button)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    func setupLayoutTableView(tables: UITableView) {
        view.subviews.forEach({ $0.removeFromSuperview() })
        view.addSubview(tables)
        
        tables.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    func setupEmptyView(entityName: String) {
        view.subviews.forEach({ $0.removeFromSuperview() })
        let emptyView = EmptyListView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.entityName = entityName
        view.addSubview(emptyView)
        
        emptyView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    func setupServerError(with: String) {
        view.subviews.forEach({ $0.removeFromSuperview() })
        let errorView = ErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.errorText = with
        view.addSubview(errorView)
        
        errorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    func setupNotConnectionError() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        let errorView = NotConnection()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorView)
        
        errorView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    func setupLoadingView() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    func setupInstallView(moduleName: String, installName: String, viewController: InstallModuleViewDelegate?) {
        guard let viewController = viewController else {
            return
        }
        view.subviews.forEach({ $0.removeFromSuperview() })
        let installView = InstallModuleView()
        installView.translatesAutoresizingMaskIntoConstraints = false
        installView.delegate = viewController
        installView.moduleName = moduleName
        installView.installName = installName
        self.view.addSubview(installView)
        
        installView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
}
