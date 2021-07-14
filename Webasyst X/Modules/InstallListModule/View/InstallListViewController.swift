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
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var userEmail: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var signOutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray5
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle(NSLocalizedString("exitAccountButtonTitle", comment: ""), for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.addTarget(self, action: #selector(signOutAccount), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var myInstallLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("myInstallWebasyst", comment: "").uppercased()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150))
        return view
    }()
    
    var addWebasystButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 10
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.contentHorizontalAlignment = .left
        let icon = UIImage(systemName: "plus.circle.fill")
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: -10)
        button.setTitle("      \(NSLocalizedString("addWebasystButton", comment: ""))", for: .normal)
        button.addTarget(self, action: #selector(addWebasystTap), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundColor")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
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
            self.userName.text = "\(profile.firstname) \(profile.lastname)"
            self.userEmail.text = profile.email
            self.profileImage.image = UIImage(data: profile.userpic_original_crop!)
        }.disposed(by: disposedBag)
    }
    
    private func setupLayout() {
        self.tableView.backgroundColor = UIColor(named: "backgroundColor")
        self.view.backgroundColor = UIColor(named: "backgroundColor")
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        profileImage.makeRounded()
        self.profileView.addSubview(profileImage)
        self.profileView.addSubview(userName)
        self.profileView.addSubview(userEmail)
        self.profileView.addSubview(myInstallLabel)
        self.footerView.addSubview(signOutButton)
        self.footerView.addSubview(addWebasystButton)
        self.tableView.tableHeaderView = profileView
        self.tableView.tableFooterView = footerView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            profileView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            profileImage.heightAnchor.constraint(equalToConstant: 100),
            profileImage.widthAnchor.constraint(equalToConstant: 100),
            profileImage.topAnchor.constraint(equalTo: profileView.topAnchor),
            profileImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            userName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10),
            userName.centerXAnchor.constraint(equalTo: self.profileView.centerXAnchor),
            userEmail.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 5),
            userEmail.centerXAnchor.constraint(equalTo: self.profileView.centerXAnchor),
            myInstallLabel.leadingAnchor.constraint(equalTo: self.profileView.leadingAnchor, constant: 20),
            myInstallLabel.trailingAnchor.constraint(equalTo: self.profileView.trailingAnchor, constant: -20),
            myInstallLabel.topAnchor.constraint(equalTo: self.userEmail.bottomAnchor, constant: 30),
            myInstallLabel.bottomAnchor.constraint(equalTo: self.profileView.bottomAnchor, constant: -5),
            footerView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor),
            footerView.bottomAnchor.constraint(equalTo: self.tableView.bottomAnchor),
            addWebasystButton.widthAnchor.constraint(equalTo: self.footerView.widthAnchor, constant: -40),
            addWebasystButton.centerXAnchor.constraint(equalTo: self.footerView.centerXAnchor),
            addWebasystButton.topAnchor.constraint(equalTo: self.footerView.topAnchor, constant: 10),
            addWebasystButton.heightAnchor.constraint(equalToConstant: 40),
            signOutButton.widthAnchor.constraint(equalTo: self.footerView.widthAnchor, constant: -40),
            signOutButton.centerXAnchor.constraint(equalTo: self.footerView.centerXAnchor),
            signOutButton.topAnchor.constraint(equalTo: self.addWebasystButton.bottomAnchor, constant: 10),
            signOutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func addWebasystTap() {
        self.viewModel.addWebasyst()
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
        if self.viewModel.installList[indexPath.row].url.contains("https://") {
            return 77
        } else {
            return 94
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectDomainUser(indexPath.row)
    }
}

extension UIImageView {
    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 50
        self.clipsToBounds = true
    }
}
