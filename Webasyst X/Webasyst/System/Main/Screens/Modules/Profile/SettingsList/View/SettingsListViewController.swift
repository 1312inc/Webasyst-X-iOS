//
//  SettingsListViewController.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Webasyst

final class SettingsListViewController: UIViewController {

    //MARK: ViewModel property
    var viewModel: SettingsListViewModel?
    var coordinator: SettingsListCoordinator?
    
    lazy var passcodeSettingsViewController = PasscodeSettingsViewController(presenter: navigationController, configuration: PasscodeLockConfiguration())
    
    private var disposeBag = DisposeBag()
    
    //MARK: Interface elements variable
    var tableView: UITableView = {
        let tableView = UITableView()
        let nibCell = UINib(nibName: "InstallViewCell", bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: InstallViewCell.id)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isUserInteractionEnabled = true
        tableView.bounces = false
        return tableView
    }()
    
    lazy var profileView: ProfileView = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(click))
        let view = ProfileView(frame: CGRect(x: 0, y: 0, width: 150, height: 200))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    lazy var footerView: FooterView = {
        let view = FooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 200), delegate: self)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindableViewModel()
        setupLayout()
        navigationItem.rightBarButtonItem?.tintColor = .appColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.appearanceColor(color: .backgroundColor)
        viewModel?.input.refreshProfile.accept(.refresh)
    }
    
    private func bindableViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        viewModel.output.installList
            .bind(to: tableView.rx.items(cellIdentifier: InstallViewCell.id,
                                         cellType: InstallViewCell.self)) { _, install, cell in
                cell.configureCell(install)
            }.disposed(by: disposeBag)

        viewModel.output.userProfileData
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] profile in
                self?.profileView.configureData(profile: profile)
            }).disposed(by: disposeBag)

        viewModel.output.userLogOutStatus
            .subscribe(onNext: { [weak self] result in
                if result {
                    guard let coordinator = self?.coordinator else { return }
                    DispatchQueue.main.async {
                        coordinator.logout()
                    }
                }
            }).disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let cell = self?.tableView.cellForRow(at: indexPath) as? InstallViewCell
                if let currentInstall = UserDefaults.standard.string(forKey: UserDefaults.activeSettingClientId),
                   let install = cell?.Install, let viewModel = self?.viewModel, cell?.Install?.id != currentInstall {
                    viewModel.input.changeActiveSetting.accept(install)
                } else {
                    self?.navigationController?.dismiss(animated: true)
                }
            }).disposed(by: disposeBag)

        viewModel.output.settingChange.subscribe { [weak self] _ in
            self?.coordinator?.dissmisViewController()
        }.disposed(by: disposeBag)

        viewModel.input.callCoordinatorComplition.subscribe { [weak self] value in
            guard let self = self else { return }
            self.coordinator?.removeAll()
            if value {
                self.coordinator?.closure()
            }
        }.disposed(by: disposeBag)
        
    }
    
    private func setupLayout() {
        view.backgroundColor = .backgroundColor
        view.addSubview(tableView)
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
        tableView.tableHeaderView = profileView
        tableView.tableHeaderView?.frame = .init(x: 0, y: 0, width: 200, height: 200)
        tableView.tableHeaderView?.isUserInteractionEnabled = true
        tableView.tableFooterView = footerView
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.right.equalTo(self.view.safeAreaLayoutGuide)
            make.left.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        
    }

}

extension SettingsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel = self.viewModel else { return 92 }
        do {
            let settingsList = try viewModel.output.installList.value()
            if settingsList[indexPath.row].url.contains("https://") {
                return 92
            } else {
                return 120
            }
        } catch {
            return 92
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 170
    }
    
}

extension SettingsListViewController: FooterViewSettingsListDelegate {
    
    func openAddNewAccount() {
        coordinator?.openAddNewAccount()
    }
    
    func openManager() {
        click()
    }
    
    func openPasscode() {
        showPasscodeAlert()
    }
}

extension SettingsListViewController {
    
    @objc func click() {
        guard let profile = try? viewModel?.output.userProfileData.value() else { return }
        coordinator?.openRedactorViewController(image: profileView.profileImage.image,
                                                profile: profile,
                                                delegate: self)
    }
    
    func showPasscodeAlert() {
        let alert = passcodeSettingsViewController.getAlertController()
        present(alert, animated: true) {
            if #available(iOS 14.0, *) {
                let dismissControl = UIControl()
                dismissControl.addAction(UIAction(handler: { _ in alert.dismiss(animated: true) }), for: .allTouchEvents)
                dismissControl.frame = alert.view.superview?.bounds ?? CGRect.zero
                alert.view.superview?.insertSubview(dismissControl, belowSubview: alert.view)
            }
        }
    }
    
}

extension SettingsListViewController: PassImageToPreviousController {
    
    func update(_ image: UIImage?) {
        profileView.profileImage.image = image
    }
    
    
}
