//
//  UIImageView.swift
//  Webasyst X
//
//  Created by Виктор Кобыхно on 26.07.2021.
//

import UIKit

extension UIImageView {
    func makeRounded() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 50
        self.clipsToBounds = true
    }
}
