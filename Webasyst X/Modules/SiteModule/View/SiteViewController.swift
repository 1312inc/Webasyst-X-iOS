//
//  SiteViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import RxSwift
import RxCocoa
import Webasyst

class SiteViewController: UIViewController {

    var webasyst = WebasystApp()
    var viewModel: SiteViewModelProtocol!
    var coordinator: SiteCoordinatorProtocol!
    private var disposedBag = DisposeBag()
    
    //MARK: Inteface element variables
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
        self.viewModel.fetchSiteList()
        self.bindableViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateData), name: Notification.Name("ChangedSelectDomain"), object: nil)
    }
    
    // Subscribe for model updates
    private func bindableViewModel() {
        
        self.viewModel.siteListSubject
            .map({ pages -> [Pages] in
                if pages.isEmpty {
                    self.setupEmptyView(entityName: NSLocalizedString("element", comment: ""))
                    return []
                } else {
                    self.setupLayoutTableView(tables: self.siteTableView)
                    return pages
                }
            })
            .bind(to: siteTableView.rx.items(cellIdentifier: SiteViewCell.identifier, cellType: SiteViewCell.self)) { _, page, cell in
                cell.configure(siteData: page)
            }.disposed(by: disposedBag)
        
        siteTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let self = self {
                    let cell = self.siteTableView.cellForRow(at: indexPath) as? SiteViewCell
                    guard let page = cell?.page else { return }
                    self.coordinator.openDetail(pageId: page.id)
                }
            }).disposed(by: disposedBag)
        
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
                    self.setupEmptyView(entityName: NSLocalizedString("element", comment: ""))
                case .requestFailed(text: let text):
                    self.setupServerError(with: text)
                case .notInstall:
                    guard let selectInstall = UserDefaults.standard.string(forKey: "selectDomainUser") else { return }
                    if let install = self.webasyst.getUserInstall(selectInstall) {
                        self.setupInstallView(moduleName: NSLocalizedString("shop", comment: ""), installName: install.name ?? "", viewController: self)
                    }
                case .notConnection:
                    self.setupNotConnectionError()
                }
            }).disposed(by: disposedBag)
        
    }
    
    @objc func updateData() {
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        if let activeDomain = webasyst.getUserInstall(selectDomain) {
            self.viewModel.changeUserDomain(activeDomain.id)
        }
    }
    
    @objc func openSetupList() {
        self.coordinator.openInstallList()
    }

}

extension SiteViewController: InstallModuleViewDelegate {
    
    func installModuleTap() {
        let alertController = UIAlertController(title: "Install module", message: "Tap in install module button", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
}
