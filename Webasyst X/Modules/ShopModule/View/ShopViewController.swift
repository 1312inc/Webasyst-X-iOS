//
//  ShopViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import RxSwift
import RxCocoa
import Webasyst

class ShopViewController: UIViewController {

    let webasyst = WebasystApp()
    var viewModel: ShopViewModelProtocol!
    
    //MARK: Inteface element variables
    lazy var ordersTableView: UITableView = {
        let tableView = UITableView()
        let uiNib = UINib(nibName: "OrderViewCell", bundle: nil)
        tableView.register(uiNib, forCellReuseIdentifier: "orderCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLoadingView()
        self.title = self.viewModel.title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        self.fetchData()
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
        self.setupLoadingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateData), name: Notification.Name("ChangedSelectDomain"), object: nil)
        self.viewModel.fetchOrderList()
    }
    
    @objc func updateData() {
        self.ordersTableView.removeFromSuperview()
        self.viewModel.fetchOrderList()
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
        self.setupLoadingView()
    }
    
    private func fetchData() {
        _ = self.viewModel.dataSource.bind { result in
            switch result {
            case .Success:
                DispatchQueue.main.async {
                    self.setupLayoutTableView(tables: self.ordersTableView)
                    self.ordersTableView.reloadData()
                }
            case .Failure(let error):
                switch error {
                case .permisionDenied:
                    DispatchQueue.main.async {
                        let localizedString = NSLocalizedString("permisionDenied", comment: "")
                        let replacedString = String(format: localizedString, "shop")
                        self.setupServerError(with: replacedString)
                    }
                case .requestFailed(let text):
                    DispatchQueue.main.async {
                        self.setupServerError(with: "\(NSLocalizedString("requestFailed", comment: ""))\n\(text)")
                    }
                case .notEntity:
                    DispatchQueue.main.async {
                        self.setupEmptyView()
                    }
                case .notInstall:
                    DispatchQueue.main.async {
                        self.setupInstallView(viewController: self)
                    }
                }
            }
        }
    }
    
    @objc func openSetupList() {
        self.viewModel.openInstallList()
    }
}

extension ShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderViewCell
        
        let order = self.viewModel.orderList[indexPath.row]
        cell.configureCell(order)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension ShopViewController: InstallModuleViewDelegate {
    
    func installModuleTap() {
        let alertController = UIAlertController(title: "Install module", message: "Tap in install module button", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
}
