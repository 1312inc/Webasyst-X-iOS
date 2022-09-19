//
//  PhotoViewCell.swift
//  Webasyst X
//
//  Created by Леонид Лукашевич on 18.09.2022.
//

import UIKit

class PhotoViewCell: UITableViewCell {

    public static var identifier = "photoCell"
    @IBOutlet var img: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    func configureCell(_ photo: Photos) {
        self.nameLabel.text = photo.name
        
        NetworkingManager().downloadImage("https://webasyst.com\(photo.image_url)") { data in
            self.img.image = UIImage(data: data)
        }
    }
    
}
