//
//  LoadingView.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 16.06.2021.
//

import UIKit

class LoadingView: UIView {

    private var activityIndicator: UIActivityIndicatorView = {
        let imageView = UIActivityIndicatorView(style: .large)
        imageView.startAnimating()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyListLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemGray2
        label.text = NSLocalizedString("loading", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        self.addSubview(activityIndicator)
        self.addSubview(emptyListLabel)
        NSLayoutConstraint.activate([
            emptyListLabel.widthAnchor.constraint(equalToConstant: self.frame.width - 20),
            emptyListLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            emptyListLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: emptyListLabel.topAnchor, constant: -10)
        ])
    }

}
