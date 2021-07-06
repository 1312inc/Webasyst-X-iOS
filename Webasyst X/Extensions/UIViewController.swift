//
//  UIViewController.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 05.07.2021.
//

import UIKit
import Webasyst

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
        NSLayoutConstraint.activate([
            tables.topAnchor.constraint(equalTo: view.topAnchor),
            tables.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tables.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tables.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    func setupEmptyView(moduleName: String, entityName: String) {
        view.subviews.forEach({ $0.removeFromSuperview() })
        let emptyView = EmptyListView()
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.moduleName = moduleName
        emptyView.entityName = entityName
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyView.heightAnchor.constraint(equalTo: view.heightAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupServerError(with: String) {
        view.subviews.forEach({ $0.removeFromSuperview() })
        let errorView = ErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.errorText = with
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    func setupLoadingView() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    func setupInstallView(moduleName: String, viewController: InstallModuleViewDelegate?) {
        guard let viewController = viewController else {
            return
        }
        view.subviews.forEach({ $0.removeFromSuperview() })
        let installView = InstallModuleView()
        installView.translatesAutoresizingMaskIntoConstraints = false
        installView.delegate = viewController
        installView.moduleName = moduleName
        self.view.addSubview(installView)
        NSLayoutConstraint.activate([
            installView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            installView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            installView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            installView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
