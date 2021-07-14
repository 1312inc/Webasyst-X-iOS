//
//  InstallViewCell.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/28/21.
//

import UIKit
import Webasyst

class InstallViewCell: UITableViewCell {

    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var checmarkImage: UIImageView!
    @IBOutlet weak var installmage: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var troubleLabel: UILabel!
    @IBOutlet weak var troubleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func configureCell(_ profileInstall: UserInstall) {
        backView.layer.cornerRadius = 10
        installmage.layer.cornerRadius = installmage.frame.width / 2
        installmage.contentMode = .scaleAspectFill
        if profileInstall.url.contains("https://") {
            troubleLabel?.removeFromSuperview()
            troubleImage?.removeFromSuperview()
        } else {
            troubleLabel?.text = NSLocalizedString("notSecureConnection", comment: "")
        }
        self.urlLabel?.text = profileInstall.name
        if let expiredDate = profileInstall.cloudExpireDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let expired = dateFormatter.date(from: expiredDate)!
            let todayDate = Date()
            if expired >= todayDate {
                dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
                let somedateString = dateFormatter.string(from: expired)
                let localizedString = NSLocalizedString("expiresOn", comment: "")
                let replacedString = String(format: localizedString, somedateString)
                self.domainLabel?.text = replacedString
            } else {
                dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
                let somedateString = dateFormatter.string(from: expired)
                let localizedString = NSLocalizedString("expiredOn", comment: "")
                let replacedString = String(format: localizedString, somedateString)
                self.domainLabel?.text = replacedString
                self.domainLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                self.domainLabel?.textColor = .red
            }
        } else {
            self.domainLabel?.text = profileInstall.url
        }
        self.installmage.image = UIImage(data: profileInstall.image!)
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        if profileInstall.id != selectDomain {
            self.checmarkImage?.isHidden = true
        }
        if let logo = profileInstall.imageLogo {
            if logo {
                companyLabel?.removeFromSuperview()
            } else {
                companyLabel?.text = profileInstall.logoText
            }
        } else {
            companyLabel?.removeFromSuperview()
        }
    }
    
}
