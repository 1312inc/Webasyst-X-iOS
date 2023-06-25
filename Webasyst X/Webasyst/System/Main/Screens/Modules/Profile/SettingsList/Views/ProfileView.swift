//
//  ProfileView.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.10.2022.
//

import UIKit
import SnapKit
import Webasyst

class ProfileView: UIView {

    lazy var profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 50
        return image
    }()
    
    var userName: UILabel = {
        let label = UILabel()
        label.font = .adaptiveFont(.title2, 22, .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    
    var userEmail: UILabel = {
        let label = UILabel()
        label.font = .adaptiveFont(.subheadline, 16)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override func layoutSubviews() {
        addSubview(userName)
        addSubview(userEmail)
        addSubview(profileImage)
        
        profileImage.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.width.equalTo(100)
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.centerX.equalTo(self)
        }
        
        userName.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.top.equalTo(profileImage.snp.bottom).offset(10)
        }
        
        userEmail.snp.makeConstraints { make in
            make.top.equalTo(userName.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
    }
    
    func configureData(profile: ProfileData) {
        profileImage.rx.image.onNext(UIImage(data: profile.userpic_original_crop ?? Data()))
        userName.rx.text.onNext(profile.name)
        userEmail.rx.text.onNext(profile.email)
    }

}

