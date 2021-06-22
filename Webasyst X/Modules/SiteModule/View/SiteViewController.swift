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
        self.title = NSLocalizedString("siteTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        self.createLeftNavigationBar()
        siteTableView.register(UINib(nibName: "SiteViewCell", bundle: nil), forCellReuseIdentifier: SiteViewCell.identifier)
        self.siteTableView.layoutMargins = UIEdgeInsets.zero
        self.siteTableView.separatorInset = UIEdgeInsets.zero
        self.setupLayoutTableView()
        self.fetchData()
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
                    self.setupLayoutTableView()
                    self.siteTableView.reloadData()
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
    
    private func createLeftNavigationBar() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        
        guard let changeInstall = self.webasyst.getUserInstall(selectDomain) else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.triangle"), style: .done, target: self, action: #selector(openSetupList))
            return
        }
        
        let imageView = UIImageView(image: UIImage(data: changeInstall.image!))
        imageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        imageView.contentMode = .scaleAspectFill
        let textImage = changeInstall.logoText
        
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        textLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight(600))
        textLabel.text = textImage
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        
        imageView.center = view.center
        textLabel.center = view.center
        
        imageView.layer.cornerRadius = view.frame.height / 2
        imageView.layer.masksToBounds = true
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(self.openSetupList), for: .touchDown)
        button.center = view.center
        
        view.addSubview(imageView)
        view.addSubview(textLabel)
        view.addSubview(button)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    @objc func updateData() {
        self.errorView.removeFromSuperview()
        self.siteTableView.removeFromSuperview()
        self.setupLoadingView()
        self.viewModel.fetchSiteList()
        self.createLeftNavigationBar()
    }
    
    private func setupLayoutTableView() {
        self.installView.removeFromSuperview()
        self.siteTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
        self.errorView.removeFromSuperview()
        self.siteTableView.tableFooterView = UIView()
        view.addSubview(siteTableView)
        NSLayoutConstraint.activate([
            siteTableView.topAnchor.constraint(equalTo: view.topAnchor),
            siteTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            siteTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            siteTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupEmptyView() {
        self.installView.removeFromSuperview()
        self.siteTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
        self.errorView.removeFromSuperview()
        emptyView.moduleName = "site"
        emptyView.entityName = "posts"
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
        self.siteTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
        self.errorView.removeFromSuperview()
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
        self.siteTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
        self.errorView.removeFromSuperview()
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
        self.siteTableView.removeFromSuperview()
        self.installView.removeFromSuperview()
        self.emptyView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
        installView.delegate = self
        installView.moduleName = "site"
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
    
}
