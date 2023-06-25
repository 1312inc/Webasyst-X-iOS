//
//  Welcome module - WelcomeModel.swift
//  Teamwork
//
//  Created by viktkobst on 19/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum SlidesType {
    case slide(data: Slide)
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

enum SlideViewType {
    case slideView(view: SlideView)
}

struct SliderViews {
    var views: SlideViewType
}
