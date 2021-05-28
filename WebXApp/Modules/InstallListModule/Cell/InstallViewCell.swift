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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func configureCell(_ profileInstall: UserInstall) {
        backView.layer.cornerRadius = 10
        installmage.layer.cornerRadius = 25
        self.urlLabel?.text = profileInstall.name
        self.domainLabel?.text = profileInstall.url
        self.installmage.image = UIImage(data: profileInstall.image!)
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        if profileInstall.id != selectDomain {
            self.checmarkImage?.removeFromSuperview()
        }
    }
    
}
