//
//  InstallViewCell.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/28/21.
//

import UIKit

class InstallViewCell: UITableViewCell {

    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var checmarkImage: UIImageView!
    @IBOutlet weak var errorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func configureCell(_ profileInstall: ProfileInstallList) {
        self.urlLabel?.text = profileInstall.domain
        self.domainLabel?.text = profileInstall.url
        if profileInstall.url?.contains("https://") ?? false {
            self.errorImage?.removeFromSuperview()
        }
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        if profileInstall.domain != selectDomain {
            self.checmarkImage?.removeFromSuperview()
        }
    }
    
}
