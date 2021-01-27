//
//  BlogViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import RxSwift
import RxCocoa

class BlogViewController: UIViewController {

    var viewModel: BlogViewModelProtocol!
    let disposedBag = DisposeBag()
    
    //MARK: Inteface element variables
    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "postCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var errorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var errorLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("loading", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        indicator.style = .large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var installButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle(NSLocalizedString("installModuleButtonTitle", comment: ""), for: .normal)
        button.backgroundColor = .systemGray5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("blogTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.triangle"), style: .done, target: self, action: #selector(openSetupList))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .done, target: self, action: #selector(openUserProfile))
        setupLayoutTableView()
        fetchData()
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
                        self.setupLayoutError()
                        self.errorLabel.text = NSLocalizedString("permisionDenied", comment: "")
                    }
                case .requestFailed:
                    DispatchQueue.main.async {
                        self.setupLayoutError()
                        self.errorLabel.text = NSLocalizedString("requestFailed", comment: "")
                    }
                case .notEntity:
                    DispatchQueue.main.async {
                        self.setupLayoutError()
                        self.errorLabel.text = NSLocalizedString("emptyBlog", comment: "")
                    }
                case .notInstall:
                    DispatchQueue.main.async {
                        self.setupInstallView()
                        self.errorLabel.text = NSLocalizedString("notInstallBlog", comment: "")
                    }
                }
            }
        }.disposed(by: disposedBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        if !self.viewModel.changeUserDomain(selectDomain) {
            self.errorView.removeFromSuperview()
            self.postTableView.removeFromSuperview()
            self.setupLoadingView()
            self.viewModel.fetchBlogPosts()
        } else {
            self.viewModel.fetchBlogPosts()
        }
    }
    
    private func setupLayoutTableView() {
        self.postTableView.tableFooterView = UIView()
        view.addSubview(postTableView)
        self.errorView.removeFromSuperview()
        self.installButton.removeFromSuperview()
        NSLayoutConstraint.activate([
            postTableView.topAnchor.constraint(equalTo: view.topAnchor),
            postTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupLayoutError() {
        self.postTableView.removeFromSuperview()
        self.view.addSubview(errorView)
        self.activityIndicator.removeFromSuperview()
        self.errorView.addSubview(errorLabel)
        self.installButton.removeFromSuperview()
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupLoadingView() {
        self.errorLabel.text = NSLocalizedString("loadingBlog", comment: "")
        self.view.addSubview(errorView)
        self.errorView.addSubview(activityIndicator)
        self.errorView.addSubview(errorLabel)
        self.installButton.removeFromSuperview()
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
            errorLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupInstallView() {
        self.errorLabel.text = NSLocalizedString("notInstallBlog", comment: "")
        self.view.addSubview(errorView)
        self.errorView.addSubview(errorLabel)
        self.errorView.addSubview(installButton)
        self.activityIndicator.removeFromSuperview()
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.widthAnchor.constraint(equalToConstant: 200),
            installButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            installButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 10),
            installButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func openSetupList() {
        self.viewModel.openInstallList()
    }
    
    @objc func openUserProfile() {
        self.viewModel.openProfileScreen()
    }
    
}

extension BlogViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.blogPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = self.viewModel.blogPosts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.openBlogEntry(indexPath.row)
    }
    
}
