//
//  BlurryView.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 10.02.2023.
//

import UIKit

final class BlurryView: UIView {
    
    func setup() {
        let blurEffect = UIBlurEffect(style: .light)
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.2)
        
        let dimmedView = UIView()
        dimmedView.backgroundColor = .reverseLabel.withAlphaComponent(0.6)
        
        addSubview(customBlurEffectView)
        addSubview(dimmedView)
        
        customBlurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bring(withAnimation animation: Bool) {
        
        if animation {
            alpha = 0
        }
        
        let blurEffect = UIBlurEffect(style: .light)
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.2)
        customBlurEffectView.frame = window?.bounds ?? bounds
        
        let dimmedView = UIView()
        dimmedView.backgroundColor = .reverseLabel.withAlphaComponent(0.6)
        dimmedView.frame = window?.bounds ?? bounds
        
        addSubview(customBlurEffectView)
        addSubview(dimmedView)
        
        if animation {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }
    }
    
    func remove(withAnimation animation: Bool) {
        
        if animation {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0
            } completion: { _ in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
    }
    
    private final class CustomVisualEffectView: UIVisualEffectView {
        
        /// Create visual effect view with given effect and its intensity
        ///
        /// - Parameters:
        ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
        ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
        init(effect: UIVisualEffect, intensity: CGFloat) {
            theEffect = effect
            customIntensity = intensity
            super.init(effect: nil)
        }
        
        required init?(coder aDecoder: NSCoder) { nil }
        
        deinit {
            animator?.stopAnimation(true)
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            effect = nil
            animator?.stopAnimation(true)
            animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
                guard let self = self else { return }
                self.effect = theEffect
            }
            animator?.fractionComplete = customIntensity
        }
        
        private let theEffect: UIVisualEffect
        private let customIntensity: CGFloat
        private var animator: UIViewPropertyAnimator?
    }
}
