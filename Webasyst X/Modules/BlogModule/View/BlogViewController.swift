//
//  BlogViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import RxSwift
import RxCocoa
import Webasyst

class BlogViewController: UIViewController {
    
    var webasyst = WebasystApp()
    var viewModel: BlogViewModelProtocol!
    var coordinator: BlogCoordinatorProtocol!
    let disposedBag = DisposeBag()
    
    //MARK: Inteface element variables
    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UINib(nibName: "BlogTableViewCell", bundle: nil), forCellReuseIdentifier: BlogTableViewCell.identifier)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("blogTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        self.setupLayoutTableView(tables: self.postTableView)
        self.viewModel.fetchBlogPosts()
        self.bindableViewModel()
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
    }
    
    // Subscribe for model updates
    private func bindableViewModel() {
        self.viewModel.blogListSubject
            .map({ posts -> [PostList] in
                if posts.isEmpty {
                    self.setupEmptyView(entityName: NSLocalizedString("post", comment: ""))
                    return []
                } else {
                    self.setupLayoutTableView(tables: self.postTableView)
                    return posts
                }
            })
            .bind(to: postTableView.rx.items(cellIdentifier: BlogTableViewCell.identifier, cellType: BlogTableViewCell.self)) { count, post, cell in
                cell.configure(post)
            }.disposed(by: disposedBag)
        
        postTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let self = self {
                    let cell = self.postTableView.cellForRow(at: indexPath) as? BlogTableViewCell
                    guard let news = cell?.postList else { return }
                    self.coordinator.openDetailBlogEntry(news)
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
                    self.setupEmptyView(entityName: NSLocalizedString("post", comment: ""))
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
    
    @objc func openSetupList() {
        self.coordinator.openInstallList()
    }
    
}

extension BlogViewController: InstallModuleViewDelegate {
    
    func installModuleTap() {
        let alertController = UIAlertController(title: "Install module", message: "Tap in install module button", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
}

