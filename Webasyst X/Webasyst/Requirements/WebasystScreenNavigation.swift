//
//  Navigation.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 06.04.2023.
//

import UIKit
import Webasyst

protocol WebasystNavigationType: WebasystScreenNavigation {
    var presenter: UINavigationController { get }
}

class WebasystScreenNavigation: CurrentUser {
    
    private unowned var parent: WebasystNavigationType!
    private let appCoordinator = AppCoordinator.shared
    
    func configure(delegate: WebasystNavigationType) {
        self.parent = delegate
    }
    
    // MARK: - Account actions
    
    func authorize(with userStatus: UserStatus, closure: () -> () = {}) {
        Service.Demo.isDemo = false
        closure()
        appCoordinator.authUser(userStatus, style: .start)
    }
    
    func openDemo() {
        Service.Demo.isDemo = true
        UserDefaults.setCurrentInstall(withValue: Service.Demo.demoToken)
        appCoordinator.pushForDemo()
    }
    
    func logout(_ closure: () -> () = {}) {
        appCoordinator.logOutUser(style: .indirect, needToRepresent: false)
        closure()
    }
    
    // MARK: - Alert
    
    func showErrorAlert(with: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: .getLocalizedString(withKey: "errorTitle"), message: with, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: .getLocalizedString(withKey: "okAlert"), style: .cancel)
            alertController.addAction(alertAction)
            self.parent.presenter.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Profile
    
    func resetViewControllers(withLoading: Bool = false) {
//        for navigationController in parent.presenter.tabBarController?.viewControllers ?? [] {
//            for controller in navigationController.children where controller is BaseViewController {
//                
//                if withLoading {
//                    (controller as? BaseViewController)?.acquireLoading.accept(true)
//                }
//                
//                if let orderViewController = controller as? OrdersViewController {
//                    
//                    orderViewController.mainDataBinding?.dispose()
//                    orderViewController.viewModel.disposeAllDisposable()
//
//                    orderViewController.viewModel.output.allDataSource.accept(nil)
//                    orderViewController.viewModel.output.inWorkDataSource.accept(nil)
//                    
//                    orderViewController.viewModel.output.tableViewDataSource.accept([])
//
//                    if orderViewController.mainDataBinding != nil {
//                        orderViewController.bindDataSource()
//                    }
//                } else if let productsViewController = controller as? ProductsViewController {
//
//                    productsViewController.mainDataBinding?.dispose()
//                    productsViewController.viewModel.disposeAllDisposable()
//                    
//                    productsViewController.viewModel.output.dataSource.accept(nil)
//                    
//                    productsViewController.viewModel.output.tableViewDataSource.accept([])
//
//                    if productsViewController.mainDataBinding != nil {
//                        productsViewController.bindDataSource()
//                    }
//                } else if let salesViewController = controller as? SalesViewController {
//                    if salesViewController.profitWebViewController?.webView != nil {
//                        salesViewController.profitWebViewController?.webView.loadHTMLString("", baseURL: nil)
//                    }
//                    if salesViewController.buyersWebViewController?.webView != nil {
//                        salesViewController.buyersWebViewController?.webView.loadHTMLString("", baseURL: nil)
//                    }
//                    if salesViewController.bestsellersWebViewController?.webView != nil {
//                        salesViewController.bestsellersWebViewController?.webView.loadHTMLString("", baseURL: nil)
//                    }
//                } else if let shopViewController = controller as? WebViewViewController {
//                    if shopViewController.webView != nil {
//                        shopViewController.webView.loadHTMLString("", baseURL: nil)
//                    }
//                }
//            }
//        }
    }
    
    func reloadViewControllers() {
        (parent.presenter.topViewController as? BaseViewController)?.reloadViewControllers()
        parent.presenter.tabBarController?.tabBar.isHidden = false
    }
    
}
