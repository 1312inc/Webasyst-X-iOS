//
//  PhotoViewController.swift
//  Webasyst X
//
//  Created by Леонид Лукашевич on 18.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import Webasyst

final class PhotoViewController: UIViewController {
    
    //MARK: ViewModel property
    var viewModel: PhotoViewModel?
    var coordinator: PhotoCoordinator?
    
    private var disposeBag = DisposeBag()
    
    //MARK: Interface elements property
    lazy var photosTableView: UITableView = {
        let tableView = UITableView()
        let uiNib = UINib(nibName: "OrderViewCell", bundle: nil)
        tableView.register(uiNib, forCellReuseIdentifier: "orderCell")
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("photoTitle", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        self.bindableViewModel()
        self.createLeftNavigationButton(action: #selector(self.openSetupList))
    }
    
    private func bindableViewModel() {
        
        guard let viewModel = self.viewModel else { return }
        
        viewModel.output.photosList
            .map({ photos -> [Photos] in
                if photos.isEmpty {
                    self.setupEmptyView(entityName: NSLocalizedString("photo", comment: ""))
                    return []
                } else {
                    self.setupLayoutTableView(tables: self.photosTableView)
                    return photos
                }
            })
            .bind(to: photosTableView.rx.items(cellIdentifier: PhotoViewCell.identifier, cellType: PhotoViewCell.self)) { _, photo, cell in
                cell.configureCell(photo)
            }.disposed(by: disposeBag)
        
        photosTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.output.showLoadingHub
            .subscribe(onNext: { [weak self] loading in
                if loading {
                    guard let self = self else { return }
                    self.setupLoadingView()
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.errorServerRequest
            .subscribe (onNext: { [weak self] errors in
                guard let self = self else { return }
                switch errors {
                case .permisionDenied:
                    self.setupServerError(with: NSLocalizedString("permisionDenied", comment: ""))
                case .notEntity:
                    self.setupEmptyView(entityName: NSLocalizedString("photo", comment: ""))
                case .requestFailed(text: let text):
                    self.setupServerError(with: text)
                case .notInstall:
                    guard let selectInstall = UserDefaults.standard.string(forKey: "selectDomainUser") else { return }
                    let webasyst = WebasystApp()
                    if let install = webasyst.getUserInstall(selectInstall) {
                        self.setupInstallView(moduleName: NSLocalizedString("photoName", comment: ""), installName: install.name ?? "", viewController: self)
                    }
                case .notConnection:
                    self.setupNotConnectionError()
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.updateActiveSetting
            .subscribe(onNext: { [weak self] update in
                guard let self = self else { return }
                self.createLeftNavigationButton(action: #selector(self.openSetupList))
            }).disposed(by: disposeBag)
    }
    
    @objc func openSetupList() {
        guard let coordinator = self.coordinator else { return }
        coordinator.openSettingsList()
    }
}

extension PhotoViewController: InstallModuleViewDelegate {
    
    func installModuleTap() {
        let alertController = UIAlertController(title: "Install module", message: "Tap in install module button", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
}

extension PhotoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 398
    }
    
}
