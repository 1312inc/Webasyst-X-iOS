//
//  LoadingView.swift
//  CRM
//
//  Created by Леонид Лукашевич on 21.12.2022.
//

import UIKit

class LoadingView: UIView, LoadingProtocol {

    private var activityIndicator: UIActivityIndicatorView = {
        let imageView = UIActivityIndicatorView(style: .large)
        imageView.startAnimating()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var loadingListLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemGray2
        label.text = .getLocalizedString(withKey: "loading")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
                
        addSubview(activityIndicator)
        addSubview(loadingListLabel)
        
        NSLayoutConstraint.activate([
            loadingListLabel.widthAnchor.constraint(equalToConstant: frame.width - 20),
            loadingListLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingListLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: loadingListLabel.topAnchor, constant: -10)
        ])
    }

}
