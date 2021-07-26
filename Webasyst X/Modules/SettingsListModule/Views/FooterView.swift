//
//  FooterView.swift
//  Teamwork
//
//  Created by Виктор Кобыхно on 22.07.2021.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol FooterViewSettingsListDelegate {
    func openAddNewAccount()
}

class FooterView: UIView {

    var viewModel: SettingsListViewModel
    var delegate: FooterViewSettingsListDelegate
    
    var signOutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray5
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitle(NSLocalizedString("exitAccountButtonTitle", comment: ""), for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var addWebasystButton: UIButton = {
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
        button.addTarget(self, action: #selector(openAddNewAccountTap), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var disposeBag = DisposeBag()
    
    init(frame: CGRect, viewModel: SettingsListViewModel, delegate: FooterViewSettingsListDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.addSubview(addWebasystButton)
        self.addSubview(signOutButton)
        
        addWebasystButton.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.top.equalTo(self).offset(10)
            make.height.equalTo(50)
        }
        
        signOutButton.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.top.equalTo(addWebasystButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
        
        signOutButton.rx.tap
            .bind(to: viewModel.input.logOutUserTap)
            .disposed(by: disposeBag)
        
    }
    
    @objc private func openAddNewAccountTap() {
        self.delegate.openAddNewAccount()
    }

}
