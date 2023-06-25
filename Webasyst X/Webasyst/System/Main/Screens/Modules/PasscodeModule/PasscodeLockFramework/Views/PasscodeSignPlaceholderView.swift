//
//  PasscodeSignPlaceholderView.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import UIKit

@IBDesignable
public class PasscodeSignPlaceholderView: UIView {
    
    public enum State {
        case Inactive
        case Active
        case DidChange
        case Success
        case Error
    }
    
    public var currentState: State = .Inactive
    
    @IBInspectable
    public var cornerRadius: CGFloat = 8 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var inactiveColor: UIColor = UIColor.systemGray5 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var activeColor: UIColor = UIColor.systemGray2 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var successColor: UIColor = UIColor.systemGreen {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable
    public var errorColor: UIColor = UIColor.red {
        didSet {
            setupView()
        }
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 16, height: 16)

    }
    
    private func setupView() {
        
        layer.cornerRadius = cornerRadius
        layer.borderColor = activeColor.cgColor
        backgroundColor = inactiveColor
    }
    
    public func traitCollectionDidChange() {
        
        var newActiveColor: UIColor
        if traitCollection.userInterfaceStyle == .dark {
            newActiveColor = .white
        } else {
            newActiveColor = .systemGray2
        }
        
        activeColor = newActiveColor
        
        switch currentState {
        case .Active:
            backgroundColor = newActiveColor
        case .Inactive, .DidChange, .Success, .Error: break
        }
    }
    
    private func colorsForState(state: State) -> (backgroundColor: UIColor, borderColor: UIColor) {
        
        switch state {
        case .Inactive: return (inactiveColor, activeColor)
        case .Active: return (activeColor, activeColor)
        case .DidChange: return (inactiveColor, activeColor)
        case .Success: return (successColor, activeColor)
        case .Error: return (errorColor, errorColor)
        }
    }
    
    public func animateState(state: State, lastSign: Bool = false) {
        
        self.currentState = state
        
        let transform: (_ duration: CGFloat, _ scale: CGFloat) -> () = { [weak self] duration, scale in
            guard let self = self else { return }
            self.layer.removeAllAnimations()
            let originalTransform = CGAffineTransform.identity
            self.transform = originalTransform
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                UIView.animate(withDuration: duration, animations: {
                    self.transform = originalTransform.scaledBy(x: scale, y: scale)
                }, completion: { successed in
                    if !successed {
                        self.transform = originalTransform.scaledBy(x: scale, y: scale)
                    }
                    UIView.animate(withDuration: duration, animations: {
                        self.transform = originalTransform
                    }, completion: { successed in
                        if !successed {
                            self.transform = originalTransform
                        }
                    })
                })
            })
        }
        
        switch state {
        case .Active, .DidChange:
            if state == .Active {
                if !lastSign {
                    transform(0.1, 1.15)
                }
            } else {
                transform(0.1, 1.15)
            }
        case .Success:
            transform(0.2, 1.3)
        case .Inactive, .Error:
            break
        }
            
        animateColor(onState: state)
    }
    
    private func animateColor(onState state: State) {
        
        let changeColors = { [weak self] in
            guard let self = self else { return }
            let colors = self.colorsForState(state: state)
            self.backgroundColor = colors.backgroundColor
            self.layer.borderColor = colors.borderColor.cgColor
        }
        
        switch state {
        case .Active, .Inactive, .Success:
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    changeColors()
                },
                completion: nil
            )
        case .DidChange:
            UIView.animate(withDuration: 0.2, animations: {
                changeColors()
            })
        case .Error:
            changeColors()
        }
    }
}
