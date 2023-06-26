//
//  AccessDeniedView.swift
//  CRM
//
//  Created by Леонид Лукашевич on 02.06.2023.
//

import UIKit

class AccessDeniedView: UIView, AccessDeniedProtocol {

    var errorText: String!
    
    private var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "accessDeniedError")?.maskWithColor(color: .lightGray)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemGray2
        label.text = .getLocalizedString(withKey: "errorAccessDenied")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        backgroundColor = .reverseLabel
        self.addSubview(icon)
        self.addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: self.frame.width - 40),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            icon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 80),
            icon.heightAnchor.constraint(equalToConstant: 80),
            icon.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -20)
        ])
    }

}
