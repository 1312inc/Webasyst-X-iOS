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
    private var disposedBag = DisposeBag()
    
    //MARK: Inteface element variables
    lazy var siteTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SiteViewCell", bundle: nil), forCellReuseIdentifier: SiteViewCell.identifier)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("siteTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
        self.fetchData()
        self.setupLoadingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateData), name: Notification.Name("ChangedSelectDomain"), object: nil)
        self.viewModel.fetchSiteList()
    }
    
    // Subscribe for model updates
    private func fetchData() {
        self.viewModel.dataSource.bind { result in
            switch result {
            case .Success(_):
                DispatchQueue.main.async {
                    self.setupLayoutTableView(tables: self.siteTableView)
                    self.siteTableView.reloadData()
                }
            case .Failure(let error):
                switch error {
                case .permisionDenied:
                    DispatchQueue.main.async {
                        let localizedString = NSLocalizedString("permisionDenied", comment: "")
                        let replacedString = String(format: localizedString, "site")
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
        }.disposed(by: disposedBag)
    }
    
    @objc func updateData() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        self.setupLoadingView()
        self.viewModel.fetchSiteList()
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
    }
    
    @objc func openSetupList() {
        self.viewModel.openInstallList()
    }

}

extension SiteViewController: InstallModuleViewDelegate {
    
    func installModuleTap() {
        print("install module tap ")
    }
}

extension SiteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.siteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SiteViewCell.identifier, for: indexPath) as! SiteViewCell
        
        let site = self.viewModel.siteList[indexPath.row]
        cell.configure(siteData: site)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pageid = self.viewModel.siteList[indexPath.row].id
        self.viewModel.openDetailSite(pagesId: pageid)
    }
    
}
