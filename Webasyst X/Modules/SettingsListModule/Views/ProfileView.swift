//
//  ProfileView.swift
//  Teamwork
//
//  Created by Виктор Кобыхно on 22.07.2021.
//

import UIKit
import SnapKit
import Webasyst

class ProfileView: UIView {

    var profileImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "BigLogo")
        image.contentMode = .scaleAspectFit
        image.makeRounded()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    var userName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var userEmail: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var myInstallLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("myInstallWebasyst", comment: "").uppercased()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        self.addSubview(profileImage)
        self.addSubview(userName)
        self.addSubview(userEmail)
        self.addSubview(myInstallLabel)
        
        profileImage.snp.makeConstraints { make in
            make.height.equalTo(100)
            make.width.equalTo(100)
            make.top.equalTo(self).offset(0)
            make.centerX.equalTo(self)
        }
        
        userName.snp.makeConstraints { make in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.top.equalTo(profileImage.snp.bottom).offset(10)
        }
        
        userEmail.snp.makeConstraints { make in
            make.top.equalTo(userName.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        myInstallLabel.snp.makeConstraints { make in
            make.top.equalTo(userEmail.snp.bottom).offset(15)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
        }
        
    }
    
    func configureData(profile: ProfileData) {
        self.profileImage.rx.image.onNext(UIImage(data: profile.userpic_original_crop ?? Data()))
        self.userName.rx.text.onNext(profile.name)
        self.userEmail.rx.text.onNext(profile.email)
    }

}
