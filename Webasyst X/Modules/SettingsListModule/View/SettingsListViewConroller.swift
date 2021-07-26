//
//  SettingsList module - SettingsListViewConroller.swift
//  Teamwork
//
//  Created by viktkobst on 21/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SettingsListViewController: UIViewController {

    //MARK: ViewModel property
    var viewModel: SettingsListViewModel?
    var coordinator: SettingsListCoordinator?
    
    private var disposeBag = DisposeBag()
    
    //MARK: Interface elements variable
    var tableView: UITableView = {
        let tableView = UITableView()
        let nibCell = UINib(nibName: "InstallViewCell", bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: InstallViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var profileView: ProfileView = {
        let view = ProfileView(frame: CGRect(x: 0, y: 0, width: 0, height: 200))
        return view
    }()
    
    lazy var footerView: FooterView = {
        let view = FooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 200), viewModel: self.viewModel!, delegate: self)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(named: "backgroundColor")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.bindableViewModel()
        self.setupLayout()
    }
    
    private func bindableViewModel() {
        guard let viewModel = self.viewModel else { return }
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.output.installList
            .bind(to: tableView.rx.items(cellIdentifier: InstallViewCell.identifier, cellType: InstallViewCell.self)) { _, install, cell in
                cell.configureCell(install)
            }.disposed(by: disposeBag)
        
        viewModel.output.userProfileData
            .subscribe(onNext: { [weak self] profile in
                guard let self = self else { return }
                self.profileView.configureData(profile: profile)
            }).disposed(by: disposeBag)
        
        viewModel.output.userLogOutStatus
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                if result {
                    guard let coordinator = self.coordinator else { return }
                    coordinator.logoutUser()
                }
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let cell = self.tableView.cellForRow(at: indexPath) as? InstallViewCell
                if let install = cell?.Install {
                    if let viewModel = self.viewModel {
                        viewModel.input.changeActiveSetting.onNext(install)
                        self.coordinator?.dissmisViewController()
                    }
                }
            }).disposed(by: disposeBag)
        
    }
    
    private func setupLayout() {
        self.tableView.backgroundColor = UIColor(named: "backgroundColor")
        self.view.backgroundColor = UIColor(named: "backgroundColor")
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        self.tableView.tableHeaderView = profileView
        self.tableView.tableFooterView = footerView
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.right.equalTo(self.view.safeAreaLayoutGuide)
            make.left.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
    }
    
    @objc private func addWebasystTap() {
        guard let coordinator = self.coordinator else { return }
        coordinator.openAddNewAccount()
    }

}

extension SettingsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel = self.viewModel else { return 77 }
        do {
            let settingsList = try viewModel.output.installList.value()
            if settingsList[indexPath.row].url.contains("https://") {
                return 77
            } else {
                return 90
            }
        } catch {
            return 77
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 170
    }
    
}

extension SettingsListViewController: FooterViewSettingsListDelegate {
    
    func openAddNewAccount() {
        guard let coordinator = self.coordinator else { return }
        coordinator.openAddNewAccount()
    }
    
    
}
