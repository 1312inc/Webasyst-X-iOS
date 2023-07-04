//
//  NewBlog module - NewBlogViewConroller.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 26/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Webasyst

final class BlogViewController: BaseViewController {

    //MARK: ViewModel property
    var viewModel: BlogViewModel?
    var coordinator: BlogCoordinator?
    
    private var disposeBag = DisposeBag()
    
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
        self.bindableViewModel()
        self.createLeftNavigationButton(action: #selector(openSettingsList))
    }
    
    // Subscribe for model updates
    private func bindableViewModel() {
        
        NotificationCenter.default.rx.notification(Service.Notify.withoutInstalls)
            .take(until: rx.deallocated)
            .subscribe { [unowned self] _ in
                DispatchQueue.main.async {
                    let webasyst = WebasystApp()
                    if let profile = webasyst.getProfileData() {
                        self.setupWithoutInstallView(profile: profile, viewController: self)
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
        
        viewModel.output.postList
            .map({ [weak self] postList -> [PostList] in
                guard let self = self else {
                    return []
                }
                if postList.isEmpty {
                    self.setupEmptyView(entityName: NSLocalizedString("post", comment: ""))
                    return []
                } else {
                    self.setupLayoutTableView(tables: self.postTableView)
                    return postList
                }
            })
            .bind(to: postTableView.rx.items(cellIdentifier: BlogTableViewCell.identifier, cellType: BlogTableViewCell.self)) { _, post, cell in
                
                cell.configure(post)
                
            }.disposed(by: disposeBag)
        
        postTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let self = self {
                    let cell = self.postTableView.cellForRow(at: indexPath) as? BlogTableViewCell
                    guard let news = cell?.postList else { return }
                    guard let coordinator = self.coordinator else { return }
                    coordinator.openBlogEntryScreen(post: news)
                }
            }).disposed(by: disposeBag)
        
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
                    self.setupEmptyView(entityName: NSLocalizedString("post", comment: ""))
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
                            self.setupWithoutInstallView(profile: profile, viewController: self)
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
