//
//  WelcomeViewModel.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/13/21.
//

import Foundation

enum SlidesType {
    case slide(data: Slide)
    case auth
}

struct WelcomeSlides {
    let title: String
    let type: SlidesType
}

struct Slide {
    let text: String
    let image: String
    
    internal init(text: String, image: String) {
        self.text = text
        self.image = image
    }
}

protocol WelcomeViewModelProtocol: AnyObject {
    var slides: [WelcomeSlides] { get }
    init(coordinator: WelcomeCoordinatorProtocol)
    func tappedLoginButton()
}

final class WelcomeViewModel: WelcomeViewModelProtocol {
    
    var slides: [WelcomeSlides] = [
        WelcomeSlides(title: NSLocalizedString("slideTitle_0", comment: ""), type: .slide(data: Slide(text: NSLocalizedString("slideText_0", comment: ""), image: "Vector"))),
        WelcomeSlides(title: NSLocalizedString("slideTitle_1", comment: ""), type: .slide(data: Slide(text: NSLocalizedString("slideText_1", comment: ""), image: "Vector-2"))),
        WelcomeSlides(title: NSLocalizedString("slideTitle_2", comment: ""), type: .slide(data: Slide(text: NSLocalizedString("slideText_2", comment: ""), image: "Vector-3"))),
        WelcomeSlides(title: "Webasyst X", type: .auth)
    ]
    
    var coordinator: WelcomeCoordinatorProtocol
    
    init(coordinator: WelcomeCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    public func tappedLoginButton() {
        coordinator.showWebAuthModal()
    }
    
}
