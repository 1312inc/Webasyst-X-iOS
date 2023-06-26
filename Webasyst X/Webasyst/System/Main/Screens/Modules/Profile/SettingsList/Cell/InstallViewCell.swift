//
//  InstallViewCell.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.10.2022.
//

import UIKit
import Webasyst

class InstallViewCell: UITableViewCell {
    
    static var id = "installCell"
    
    override open var frame: CGRect {
        get {
            super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.y += 5
            frame.size.height -= 5
            super.frame = frame
        }
    }
    
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var installmage: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var troubleView: UIView!
    @IBOutlet weak var troubleLabel: UILabel!
    public var Install: UserInstall?
    private var companyLabel = UILabel()
    
    
    public func configureCell(_ profileInstall: UserInstall) {
        
        Install = profileInstall
        
        backView.layer.cornerRadius = 13
        backView.layer.masksToBounds = false
        installmage.layer.cornerRadius = installmage.frame.width / 2
        installmage.contentMode = .scaleAspectFill
        
        if profileInstall.url.contains("https://") {
            troubleView.isHidden = true
        } else {
            troubleView.isHidden = false
            troubleLabel?.text = .getLocalizedString(withKey: "notSecureConnection")
        }
        urlLabel?.text = profileInstall.name
        
        if let expiredDate = profileInstall.cloudExpireDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let expired = dateFormatter.date(from: expiredDate)!
            let todayDate = Date()
            if expired >= todayDate {
                dateFormatter.dateFormat = "dd MMM YYYY"
                let somedateString = dateFormatter.string(from: expired)
                let localizedString = String.getLocalizedString(withKey: "expiresOn")
                let replacedString = String(format: localizedString, somedateString)
                domainLabel?.text = replacedString
            } else {
                dateFormatter.dateFormat = "dd MMM YYYY"
                let somedateString = dateFormatter.string(from: expired)
                let localizedString = String.getLocalizedString(withKey: "expiredOn")
                let replacedString = String(format: localizedString, somedateString)
                domainLabel?.text = replacedString
                domainLabel?.font = .adaptiveFont(.footnote, 15)
                domainLabel?.textColor = .red
            }
        } else if let scheme = URLComponents(string: profileInstall.url),
                  let host = scheme.host?.replacingOccurrences(of: "//", with: "") {
            domainLabel?.text = host + scheme.path
        }
        
        installmage.image = UIImage(data: profileInstall.image!)
        
        if profileInstall.id == .currentInstall {
            backView.backgroundColor = .init(rgb: 0x0A84FF)
            urlLabel.textColor = .white
            domainLabel.textColor = .white.withAlphaComponent(0.7)
        }
        
        if let logo = profileInstall.imageLogo, !logo {
            installmage.addSubview(companyLabel)
            companyLabel.text = profileInstall.logoText
            companyLabel.textColor = .white
            companyLabel.font = .systemFont(ofSize: 14, weight: .bold)
            companyLabel.textAlignment = .center
            
            companyLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
        }
    }
    
    override func prepareForReuse() {
        installmage.image = nil
        companyLabel.text = nil
        backView.backgroundColor = .systemBackground
        urlLabel.textColor = .label
        domainLabel.textColor = .systemGray
    }
    
    func adaptiveFonts() {
        urlLabel.font = .adaptiveFont(.headline, 17, .semibold)
        domainLabel.font = .adaptiveFont(.footnote, 15)
    }
    
}
