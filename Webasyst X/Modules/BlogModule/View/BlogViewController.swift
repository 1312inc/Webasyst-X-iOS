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
    let disposedBag = DisposeBag()
    
    //MARK: Inteface element variables
    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.register(UINib(nibName: "BlogTableViewCell", bundle: nil), forCellReuseIdentifier: BlogTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("blogTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        self.fetchData()
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
        self.setupLoadingView()
    }
    
    // Subscribe for model updates
    private func fetchData() {
        self.viewModel.dataSource.bind { result in
            switch result {
            case .Success(_):
                DispatchQueue.main.async {
                    self.setupLayoutTableView(tables: self.postTableView)
                    self.postTableView.reloadData()
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
        }.disposed(by: disposedBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateData), name: Notification.Name("ChangedSelectDomain"), object: nil)
        self.viewModel.fetchBlogPosts()
    }
    
    @objc func updateData() {
        self.viewModel.fetchBlogPosts()
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
        self.setupLoadingView()
    }
    
    @objc func openSetupList() {
        self.viewModel.openInstallList()
    }
    
}

extension BlogViewController: InstallModuleViewDelegate {
    func installModuleTap() {
        print("install module tap ")
    }
}

extension BlogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.blogPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BlogTableViewCell.identifier, for: indexPath) as! BlogTableViewCell
        
        let post = self.viewModel.blogPosts[indexPath.row]
        cell.configure(post)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.openBlogEntry(indexPath.row)
    }
    
}

