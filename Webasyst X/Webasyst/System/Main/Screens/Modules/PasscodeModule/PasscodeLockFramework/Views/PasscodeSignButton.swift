//
//  PasscodeSignButton.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

@IBDesignable
public class PasscodeSignButton: UIButton {
    
    @IBInspectable
    public var passcodeSign: String = "1"
    
    @IBInspectable
    public var borderColor: UIColor = .clear {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var borderRadius: CGFloat = 40 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var highlightBackgroundColor: UIColor = .clear {
        didSet {
            setupView()
        }
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
        setupActions()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setupActions()
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 64, height: 64)

    }
    
    private var defaultBackgroundColor = UIColor.clear
    
    private func setupView() {
        
        titleLabel?.tintColor = .label
        
        layer.borderWidth = 2
        layer.cornerRadius = borderRadius
        layer.borderColor = borderColor.cgColor
        
        if let backgroundColor = backgroundColor {
            
            defaultBackgroundColor = backgroundColor
        }
    }
    
    private func setupActions() {
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchDragOutside, .touchCancel])
    }
    
    @objc func handleTouchDown() {
        
        animateBackgroundColor(color: highlightBackgroundColor)
    }
    
    @objc func handleTouchUp() {
        
        animateBackgroundColor(color: defaultBackgroundColor)
    }
    
    private func animateBackgroundColor(color: UIColor) {
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.backgroundColor = color
            },
            completion: nil
        )
    }
    
    public func traitCollectionDidChange() {
        
        if traitCollection.userInterfaceStyle == .dark {
            highlightBackgroundColor = .systemGray5
        } else {
            highlightBackgroundColor = .systemGray4
        }
    }
}
