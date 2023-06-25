//
//  Site module - SiteViewConroller.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Webasyst

final class SiteViewController: BaseViewController {

    //MARK: ViewModel property
    var viewModel: SiteViewModel?
    var coordinator: SiteCoordinator?
    
    private var disposeBag = DisposeBag()
    
    //MARK: Interface elements property
    lazy var siteTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UINib(nibName: "SiteViewCell", bundle: nil), forCellReuseIdentifier: SiteViewCell.identifier)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("siteTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
        self.bindableViewModel()
    }
    
    // Subscribe for model updates
    private func bindableViewModel() {
        
        guard let viewModel = self.viewModel else { return }
        
        viewModel.output.pageList
            .map { pagesList -> [Pages] in
                if pagesList.isEmpty {
                    self.setupEmptyView(entityName: NSLocalizedString("element", comment: ""))
                    return []
                } else {
                    self.setupLayoutTableView(tables: self.siteTableView)
                    return pagesList
                }
            }
            .bind(to: siteTableView.rx.items(cellIdentifier: SiteViewCell.identifier, cellType: SiteViewCell.self)) { _, page, cell in
                cell.configure(siteData: page)
            }.disposed(by: disposeBag)
        
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
                    self.setupEmptyView(entityName: NSLocalizedString("element", comment: ""))
                case .requestFailed(text: let text), .missingToken(text: let text):
                    self.setupServerError(with: text)
                case .withoutInstalls:
                    break
                case .notInstall:
                    guard let selectInstall = UserDefaults.standard.string(forKey: "selectDomainUser") else { return }
                    let webasyst = WebasystApp()
                    if let install = webasyst.getUserInstall(selectInstall) {
                        self.setupInstallView(install: install, viewController: self)
                    }
                case .notConnection:
                    self.setupNotConnectionError()
                case .withoutError:
                    break
                }
            }).disposed(by: disposeBag)

        siteTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let self = self {
                    let cell = self.siteTableView.cellForRow(at: indexPath) as? SiteViewCell
                    guard let page = cell?.page else { return }
                    guard let coordinator = self.coordinator else { return }
                    coordinator.openDetailSiteScreen(page: page.id)
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.updateActiveSetting
            .subscribe(onNext: { [weak self] update in
                guard let self = self else { return }
                self.createLeftNavigationButton(action: #selector(self.openSetupList))
            }).disposed(by: disposeBag)
        
    }
    
    @objc func openSetupList() {
        guard let coordinator = self.coordinator else { return }
        coordinator.openSettingsList { [weak self] in
            guard let self = self else { return }
            reloadViewControllers()
        }
    }
    
}
