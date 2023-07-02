//
//  UIViewController.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 05.07.2021.
//

import Webasyst
import SnapKit

extension UIViewController {
    
    internal func createLeftNavigationButton(action: Selector = .init("")) {
        let webasyst = WebasystApp()
        if Service.Demo.isDemo {
            let item = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeDemo))
            self.navigationItem.setLeftBarButtonItems([item], animated: false)
        } else if let changeInstall = webasyst.getUserInstall(.currentInstall) {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            view.layer.name = "customView"
            let imageView = UIImageView()
            let textImage = changeInstall.logoText
            webasyst.getAllUserInstall {
                if let array = $0, array.count > 1 {
                    let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
                    textLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                    textLabel.text = textImage
                    textLabel.textColor = .white
                    textLabel.textAlignment = .center
                    textLabel.center = view.center
                    imageView.addSubview(textLabel)
                    imageView.image = UIImage(data: changeInstall.image!)
                } else if let profile = webasyst.getProfileData(),
                          let data = profile.userpic_original_crop,
                          let image = UIImage(data: data) {
                    imageView.image = image
                }
            }
            imageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            imageView.contentMode = .scaleAspectFill
            
            imageView.center = view.center
            
            imageView.layer.cornerRadius = view.frame.height / 2
            imageView.layer.masksToBounds = true
            
            imageView.layer.borderWidth = 0.5
            imageView.layer.borderColor = UIColor.systemGray2.cgColor
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: action)
            
            view.addSubview(imageView)
            view.addGestureRecognizer(gestureRecognizer)
            
            if navigationItem.leftBarButtonItem == nil {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
            } else {
                self.navigationItem.leftBarButtonItem?.customView = view
            }
        }
    }
    
    @objc private
    func closeDemo() {
        AppCoordinator.shared.tabBarCoordinator.goBackToAuth()
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
    
    func setupInstallView(install: UserInstall, viewController: InstallDelegate?) {
        guard let viewController = viewController else {
            return
        }
        view.subviews.forEach({ $0.removeFromSuperview() })
        let installView = InstallView(install: install)
        installView.translatesAutoresizingMaskIntoConstraints = false
        installView.delegate = viewController
        self.view.addSubview(installView)
        
        installView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
    }
    
    func setupWithoutInstallsView(profile: ProfileData, viewController: AddAccountDelegate?) {
        guard let viewController = viewController as? BaseViewController else {
            return
        }
        view.subviews.forEach({ $0.removeFromSuperview() })
        let withoutInstallsView = AddAccountView(bottomBlock: false)
        withoutInstallsView.translatesAutoresizingMaskIntoConstraints = false
        withoutInstallsView.delegate = viewController
        withoutInstallsView.configure(email: profile.email)
        self.view.addSubview(withoutInstallsView)
        
        withoutInstallsView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        self.navigationItem.title = nil
        self.navigationItem.largeTitleDisplayMode = .never
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("exitAccountButtonTitle", comment: ""),
            style: .done,
            target: self,
            action: #selector(viewController.logOut)
        )
    }
}
