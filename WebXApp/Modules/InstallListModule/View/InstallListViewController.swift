//
//  InstallListViewController.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/18/21.
//

import UIKit
import RxSwift
import RxCocoa

class InstallListViewController: UIViewController {
    
    var viewModel: InstallListViewModelProtocol!
    let disposedBag = DisposeBag()
    
    //MARK: Interface elements variable
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        let nibCell = UINib(nibName: "InstallViewCell", bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: "installCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var profileView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var profileImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "BigLogo")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    var userName: UILabel = {
        let label = UILabel()
        label.text = "Иванов Иван Иванович"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var userEmail: UILabel = {
        let label = UILabel()
        label.text = "ViktkobST@gmail.com"
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var signOutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray5
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle(NSLocalizedString("exitAccountButtonTitle", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(signOutAccount), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        return view
    }()
    
    var addWebasystButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray5
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle(NSLocalizedString("addWebasystButton", comment: ""), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        self.fetchData()
        self.setupLayout()
        self.fetchProfileData()
    }
    
    private func fetchData() {
        self.viewModel.dataSource.bind { (result) in
            switch result {
            case .Success(_):
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            default:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }.disposed(by: disposedBag)
    }
    
    func fetchProfileData() {
        self.viewModel.getUserData().bind { profile in
            self.userName.text = "\(profile.firstName == "" ? " " : profile.firstName ?? "")  \(profile.lastName == "" ? " " : profile.lastName ?? "")"
            self.userEmail.text = profile.email
            self.profileImage.image = UIImage(data: profile.userPic!)
        }.disposed(by: disposedBag)
    }
    
    private func setupLayout() {
        self.view.addSubview(tableView)
        self.profileView.addSubview(profileImage)
        self.profileView.addSubview(userName)
        self.profileView.addSubview(userEmail)
        self.profileView.addSubview(signOutButton)
        self.footerView.addSubview(addWebasystButton)
        self.tableView.tableHeaderView = profileView
        self.tableView.tableFooterView = footerView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            profileView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            profileImage.heightAnchor.constraint(equalToConstant: 80),
            profileImage.widthAnchor.constraint(equalToConstant: 80),
            profileImage.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 10),
            profileImage.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 20),
            userName.centerYAnchor.constraint(equalTo: self.profileImage.centerYAnchor, constant: -20),
            userName.leadingAnchor.constraint(equalTo: self.profileImage.trailingAnchor, constant: 10),
            userName.trailingAnchor.constraint(equalTo: self.profileView.trailingAnchor, constant: -20),
            userEmail.centerYAnchor.constraint(equalTo: self.profileImage.centerYAnchor, constant: 20),
            userEmail.leadingAnchor.constraint(equalTo: self.profileImage.trailingAnchor, constant: 10),
            userEmail.trailingAnchor.constraint(equalTo: self.profileView.trailingAnchor, constant: -20),
            signOutButton.topAnchor.constraint(equalTo: self.profileImage.bottomAnchor, constant: 10),
            signOutButton.leadingAnchor.constraint(equalTo: self.profileView.leadingAnchor, constant: 20),
            signOutButton.trailingAnchor.constraint(equalTo: self.profileView.trailingAnchor, constant: -20),
            signOutButton.bottomAnchor.constraint(equalTo: self.profileView.bottomAnchor, constant: -10),
            addWebasystButton.leadingAnchor.constraint(equalTo: self.footerView.leadingAnchor, constant: 20),
            addWebasystButton.trailingAnchor.constraint(equalTo: self.footerView.trailingAnchor, constant: -20),
            addWebasystButton.topAnchor.constraint(equalTo: self.footerView.topAnchor, constant: 10),
            addWebasystButton.bottomAnchor.constraint(equalTo: self.footerView.bottomAnchor, constant: -10)
        ])
    }
    
    @objc func signOutAccount() {
        self.viewModel.sinOutAccount()
    }
    
}

extension InstallListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.installList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "installCell", for: indexPath) as! InstallViewCell
        
        let install = self.viewModel.installList[indexPath.row]
        cell.configureCell(install)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectDomainUser(indexPath.row)
    }
}
