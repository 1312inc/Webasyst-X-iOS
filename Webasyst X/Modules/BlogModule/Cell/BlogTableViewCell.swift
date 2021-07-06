//
//  BlogTableViewCell.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 28.05.2021.
//

import UIKit
import Webasyst

class BlogTableViewCell: UITableViewCell {

    public static var identifier = "BlogCell"
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorName: UILabel!
    var postList: PostList?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func configure(_ news: PostList) {
        self.postList = news
        self.titleLabel?.text = news.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myDate = dateFormatter.date(from: news.datetime)!
        
        dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
        let somedateString = dateFormatter.string(from: myDate)
        self.authorName?.text = "\(news.user?.name ?? ""), \(somedateString)"
        let selectDomain = UserDefaults.standard.string(forKey: "selectDomainUser") ?? ""
        let install = WebasystApp().getUserInstall(selectDomain)
        NetworkingManager().downloadImage("\(install?.url ?? "")\(news.user?.photo_url_20 ?? "")") { image in
            self.userAvatar?.image = UIImage(data: image)
            self.userAvatar.layer.cornerRadius = 15
        }
    }
    
}
