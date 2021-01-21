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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "postCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Блог"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.triangle"), style: .done, target: self, action: #selector(openSetupList))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .done, target: self, action: #selector(openUserProfile))
        setupLayout()
        fetchData()
    }
    
    private func fetchData() {
        self.viewModel.fetchBlogPosts().bind(to: postTableView.rx.items(cellIdentifier: "postCell")) {index, post, cell in
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = post.title
        }.disposed(by: disposedBag)
    }
    
    private func setupLayout() {
        self.postTableView.tableFooterView = UIView()
        view.addSubview(postTableView)
        NSLayoutConstraint.activate([
            postTableView.topAnchor.constraint(equalTo: view.topAnchor),
            postTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    @objc func openSetupList() {
        self.viewModel.openInstallList()
    }
    
    @objc func openUserProfile() {
        self.viewModel.openProfileScreen()
    }
    
}
