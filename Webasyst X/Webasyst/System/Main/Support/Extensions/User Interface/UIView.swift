//
//  UIView.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 07.04.2023.
//

import UIKit

extension UIView {
    
    func animateTap() {
        
        self.alpha = 0.5
        UIView.animate(withDuration: 0.15, delay: 0.15, options: [.allowUserInteraction, .curveLinear]) { [weak self] in
            self?.alpha = 1
        }
    }
    
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
