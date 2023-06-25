//
//  UILabel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 31.03.2023.
//

import UIKit

extension UILabel {
    
    func getSize(constrainedWidth: CGFloat) -> CGSize {
        return systemLayoutSizeFitting(CGSize(width: constrainedWidth, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}
