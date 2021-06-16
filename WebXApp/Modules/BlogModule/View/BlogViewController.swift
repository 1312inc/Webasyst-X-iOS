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
    
    var viewModel: BlogViewModelProtocol!
    let disposedBag = DisposeBag()
    
    //MARK: Inteface element variables
    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var errorView: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var installView: InstallModuleView = {
        let view = InstallModuleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var emptyView: EmptyListView = {
        let view = EmptyListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("blogTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.triangle"), style: .done, target: self, action: #selector(openSetupList))
        postTableView.register(UINib(nibName: "BlogTableViewCell", bundle: nil), forCellReuseIdentifier: BlogTableViewCell.identifier)
        self.postTableView.layoutMargins = UIEdgeInsets.zero
        self.postTableView.separatorInset = UIEdgeInsets.zero
        self.setupLayoutTableView()
        self.fetchData()
    }
    
    // Subscribe for model updates
    private func fetchData() {
        self.viewModel.dataSource.bind { result in
            switch result {
            case .Success(_):
                DispatchQueue.main.async {
                    self.setupLayoutTableView()
                    self.postTableView.reloadData()
                }
            case .Failure(let error):
                switch error {
                case .permisionDenied:
                    DispatchQueue.main.async {
                        self.setupServerError(with: NSLocalizedString("permisionDenied", comment: ""))
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
                        self.setupInstallView()
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
        self.errorView.removeFromSuperview()
        self.postTableView.removeFromSuperview()
        self.setupLoadingView()
        self.viewModel.fetchBlogPosts()
    }
    
    private func setupLayoutTableView() {
        self.installView.removeFromSuperview()
        self.postTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
        self.postTableView.tableFooterView = UIView()
        view.addSubview(postTableView)
        NSLayoutConstraint.activate([
            postTableView.topAnchor.constraint(equalTo: view.topAnchor),
            postTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupEmptyView() {
        self.installView.removeFromSuperview()
        self.postTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
        emptyView.moduleName = "shop"
        emptyView.entityName = "orders"
        self.view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupServerError(with: String) {
        self.installView.removeFromSuperview()
        self.postTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
        errorView.errorText = with
        self.view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupLoadingView() {
        self.installView.removeFromSuperview()
        self.postTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupInstallView() {
        self.installView.removeFromSuperview()
        self.postTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
        installView.delegate = self
        installView.moduleName = "shop"
        self.view.addSubview(installView)
        NSLayoutConstraint.activate([
            installView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            installView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            installView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            installView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
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
