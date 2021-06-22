//
//  EmptyListView.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 16.06.2021.
//

import UIKit

class EmptyListView: UIView {

    var moduleName: String!
    var entityName: String!
    
    private var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyImage")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyListLabel: UILabel = {
        let label = UILabel()
        let localizedString = NSLocalizedString("emptyList", comment: "")
        let replacedString = String(format: localizedString, moduleName, entityName)
        label.textColor = UIColor.systemGray2
        label.text = replacedString
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        self.addSubview(icon)
        self.addSubview(emptyListLabel)
        NSLayoutConstraint.activate([
            emptyListLabel.widthAnchor.constraint(equalToConstant: self.frame.width - 20),
            emptyListLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            emptyListLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            icon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 80),
            icon.heightAnchor.constraint(equalToConstant: 80),
            icon.bottomAnchor.constraint(equalTo: emptyListLabel.topAnchor, constant: -20)
        ])
    }

}
