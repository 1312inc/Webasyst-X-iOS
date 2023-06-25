//
//  PayWallStaticCell.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 19.12.2022.
//

import UIKit

class PayWallStaticCell: UICollectionViewCell {
    
    static var identifier = "PayWallStaticCell"
    
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        let image: UIImage? = .init(named: "check") ?? nil
        let imageWithTintColor = image?.withRenderingMode(.alwaysTemplate)
        imageView.image = imageWithTintColor
        imageView.tintColor = .systemGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public var label: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(7.5)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().inset(5)
            make.right.equalTo(label.snp_left).offset(-5)
            make.width.equalTo(12.5)
        }
        
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
        
    }
    
}
