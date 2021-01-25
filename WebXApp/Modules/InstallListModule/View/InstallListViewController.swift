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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "installCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.title
        setupLayout()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        viewModel.fetchInstallList().bind(to: tableView.rx.items(cellIdentifier: "installCell")) { index, viewModel, cell in
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = viewModel.domain
            if viewModel.domain == self.viewModel.selectDomain {
                cell.accessoryType = .checkmark
            }
            cell.separatorInset = .zero
        }.disposed(by: disposedBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            let cell = self?.tableView.cellForRow(at: indexPath)
            self?.viewModel.selectDomain = cell?.textLabel?.text ?? ""
        }).disposed(by: disposedBag)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(tappedSuccess))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(tappedCancel))
    }
    
    private func setupLayout() {
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    @objc func tappedSuccess() {
        self.viewModel.selectDomainUser()
    }
    
    @objc func tappedCancel() {
        self.viewModel.cancelSelectDomain()
    }

}
