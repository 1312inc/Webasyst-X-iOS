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
    var coordinator: ShopCoordinatorProtocol!
    
    private var disposedBag = DisposeBag()
    
    //MARK: Inteface element variables
    lazy var ordersTableView: UITableView = {
        let tableView = UITableView()
        let uiNib = UINib(nibName: "OrderViewCell", bundle: nil)
        tableView.register(uiNib, forCellReuseIdentifier: "orderCell")
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("shopTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        self.viewModel.fetchOrderList()
        self.bindableViewModel()
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateData), name: Notification.Name("ChangedSelectDomain"), object: nil)
    }
    
    @objc func updateData() {
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        if let activeDomain = webasyst.getUserInstall(selectDomain) {
            self.viewModel.changeUserDomain(activeDomain.id)
        }
    }
    
    private func bindableViewModel() {
        self.viewModel.shopListSubject
            .map({ orders -> [Orders] in
                if orders.isEmpty {
                    self.setupEmptyView(moduleName: NSLocalizedString("shop", comment: ""), entityName: NSLocalizedString("order", comment: ""))
                    return []
                } else {
                    self.setupLayoutTableView(tables: self.ordersTableView)
                    return orders
                }
            })
            .bind(to: ordersTableView.rx.items(cellIdentifier: OrderViewCell.identifier, cellType: OrderViewCell.self)) { _, order, cell in
                cell.configureCell(order)
            }.disposed(by: disposedBag)
        
        self.viewModel.isLoadingSubject
            .subscribe(onNext: { loading in
                if loading {
                    self.setupLoadingView()
                }
            }).disposed(by: disposedBag)
        
        self.viewModel.errorRequestSubject
            .subscribe (onNext: { errors in
                switch errors {
                case .permisionDenied:
                    self.setupServerError(with: NSLocalizedString("permisionDenied", comment: ""))
                case .notEntity:
                    self.setupEmptyView(moduleName: NSLocalizedString("shop", comment: ""), entityName: NSLocalizedString("order", comment: ""))
                case .requestFailed(text: let text):
                    self.setupServerError(with: text)
                case .notInstall:
                    self.setupInstallView(moduleName: NSLocalizedString("shop", comment: ""), viewController: self)
                }
            }).disposed(by: disposedBag)
    }
    
    @objc func openSetupList() {
        self.coordinator.openInstallList()
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
