//
//  SlideView.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 15.06.2021.
//

import UIKit

protocol SlideViewDelegate {
    func nextButtonTap()
}

class SlideView: UIView {
    
    @IBOutlet weak var imageSlide: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    var delegate: SlideViewDelegate!
    
    override func didMoveToSuperview() {
        nextButton.layer.cornerRadius = 10
        nextButton.setTitle(NSLocalizedString("nextButton", comment: ""), for: .normal)
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
        self.delegate.nextButtonTap()
    }
    
    
}
