//
//  Shop module - ShopViewConroller.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Webasyst

final class ShopViewController: BaseViewController {

    //MARK: ViewModel property
    var viewModel: ShopViewModel?
    var coordinator: ShopCoordinator?
    
    private var disposeBag = DisposeBag()
    
    //MARK: Interface elements property
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
        self.bindableViewModel()
        self.createLeftNavigationButton(action: #selector(openSettingsList))
    }
    
    private func bindableViewModel() {
        
        NotificationCenter.default.rx.notification(Service.Notify.withoutInstalls)
            .take(until: rx.deallocated)
            .subscribe { [unowned self] _ in
                DispatchQueue.main.async {
                    let webasyst = WebasystApp()
                    if let profile = webasyst.getProfileData() {
                        self.setupWithoutInstall(profile: profile, viewController: self)
                    }
                }
            }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Service.Notify.accountSwitched)
            .take(until: rx.deallocated)
            .subscribe { [unowned self] _ in
                DispatchQueue.main.async {
                    self.reloadViewControllers()
                }
            }.disposed(by: disposeBag)
        
        guard let viewModel = self.viewModel else { return }
        
        viewModel.output.ordersList
            .map({ orders -> [Orders] in
                if orders.isEmpty {
                    self.setupEmptyView(entityName: NSLocalizedString("order", comment: ""))
                    return []
                } else {
                    self.setupLayoutTableView(tables: self.ordersTableView)
                    return orders
                }
            })
            .bind(to: ordersTableView.rx.items(cellIdentifier: OrderViewCell.identifier, cellType: OrderViewCell.self)) { _, order, cell in
                cell.configureCell(order)
            }.disposed(by: disposeBag)
        
        ordersTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.output.showLoadingHub
            .subscribe(onNext: { [weak self] loading in
                if loading {
                    guard let self = self else { return }
                    self.setupLoadingView()
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.errorServerRequest
            .subscribe (onNext: { [weak self] errors in
                guard let self = self else { return }
                switch errors {
                case .accessDenied:
                    self.setupServerError(with: NSLocalizedString("permisionDenied", comment: ""))
                case .notEntity:
                    self.setupEmptyView(entityName: NSLocalizedString("order", comment: ""))
                case .requestFailed(text: let text), .missingToken(text: let text):
                    self.setupServerError(with: text)
                case .withoutInstalls:
                    break
                case .notInstall:
                    if let selectInstall = UserDefaults.standard.string(forKey: "selectDomainUser") {
                        let webasyst = WebasystApp()
                        if let install = webasyst.getUserInstall(selectInstall) {
                            self.setupInstallView(install: install, viewController: self)
                        }
                    } else {
                        let webasyst = WebasystApp()
                        if let profile = webasyst.getProfileData() {
                            self.setupWithoutInstall(profile: profile, viewController: self)
                        }
                    }
                case .notConnection:
                    self.setupNotConnectionError()
                case .withoutError:
                    break
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.updateActiveSetting
            .subscribe(onNext: { [weak self] update in
                guard let self = self else { return }
                self.createLeftNavigationButton(action: #selector(openSettingsList))
            }).disposed(by: disposeBag)
    }
}

extension ShopViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
}
