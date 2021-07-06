//
//  SiteViewCell.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 22.06.2021.
//

import UIKit

class SiteViewCell: UITableViewCell {

    static var identifier = "siteCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var page: Pages?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(siteData: Pages) {
        self.page = siteData
        self.titleLabel?.text = siteData.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myDate = dateFormatter.date(from: siteData.update_datetime)!
        
        dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
        let somedateString = dateFormatter.string(from: myDate)
        self.dateLabel?.text = somedateString
    }
    
}
