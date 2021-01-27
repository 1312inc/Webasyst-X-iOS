//
//  ShopViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import RxSwift
import RxCocoa

class ShopViewController: UIViewController {

    var viewModel: ShopViewModelProtocol!
    
    //MARK: Inteface element variables
    lazy var ordersTableView: UITableView = {
        let tableView = UITableView()
        let uiNib = UINib(nibName: "OrderViewCell", bundle: nil)
        tableView.register(uiNib, forCellReuseIdentifier: "orderCell")
        tableView.delegate = self
        tableView.dataSource = self
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
        self.title = self.viewModel.title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.triangle"), style: .done, target: self, action: #selector(openSetupList))
        view.backgroundColor = .systemBackground
        self.fetchData()
        self.setupLayoutTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        if !self.viewModel.changeUserDomain(selectDomain) {
            self.errorView.removeFromSuperview()
            self.ordersTableView.removeFromSuperview()
            self.setupLoadingView()
            self.viewModel.fetchOrderList()
        } else {
            self.viewModel.fetchOrderList()
        }
    }
    
    private func fetchData() {
        _ = self.viewModel.dataSource.bind { result in
            switch result {
            case .Success:
                DispatchQueue.main.async {
                    self.setupLayoutTableView()
                    self.ordersTableView.reloadData()
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
                        self.errorLabel.text = NSLocalizedString("emptyShop", comment: "")
                    }
                case .notInstall:
                    DispatchQueue.main.async {
                        self.setupInstallView()
                        self.errorLabel.text = NSLocalizedString("notInstallShop", comment: "")
                    }
                }
            }
        }
    }
    
    private func setupLayoutTableView() {
        self.ordersTableView.tableFooterView = UIView()
        view.addSubview(ordersTableView)
        self.errorView.removeFromSuperview()
        self.installButton.removeFromSuperview()
        NSLayoutConstraint.activate([
            ordersTableView.topAnchor.constraint(equalTo: view.topAnchor),
            ordersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ordersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ordersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupLayoutError() {
        self.ordersTableView.removeFromSuperview()
        self.installButton.removeFromSuperview()
        self.view.addSubview(errorView)
        self.activityIndicator.removeFromSuperview()
        self.errorView.addSubview(errorLabel)
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
        self.errorLabel.text = NSLocalizedString("loading", comment: "")
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
        self.errorLabel.text = NSLocalizedString("notInstallShop", comment: "")
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
}

extension ShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderViewCell
        
        let order = self.viewModel.orderList[indexPath.row]
        cell.configureCell(order)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
}
