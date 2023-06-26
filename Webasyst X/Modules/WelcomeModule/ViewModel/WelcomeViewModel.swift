//
//  Welcome module - WelcomeViewModel.swift
//  Teamwork
//
//  Created by viktkobst on 19/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//MARK: WelcomeViewModel
protocol WelcomeViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: WelcomeViewModel
final class WelcomeViewModel: WelcomeViewModelType {

    struct Input {
        var generateSlides: AnyObserver<Void>
    }
    
    let input: Input
    
    struct Output {
        var slides: BehaviorSubject<[WelcomeSlides]>
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
            
    //MARK: Input Objects
    private var generateSlidesSubject = PublishSubject<Void>()
    
    //MARK: Output Objects
    private var slidesSubject = BehaviorSubject<[WelcomeSlides]>(value: [])

    init() {
        //Init input property
        self.input = Input(
            generateSlides: generateSlidesSubject.asObserver()
        )

        //Init output property
        self.output = Output(
            slides: self.slidesSubject
        )
        
        self.generateSides()
    }
    
    func generateSides() {
        
        let slides: [WelcomeSlides] = [
            WelcomeSlides(title: NSLocalizedString("slideTitle_0", comment: ""), type: .slide(data: Slide(text: NSLocalizedString("slideText_0", comment: ""), image: "slide-1"))),
            WelcomeSlides(title: NSLocalizedString("slideTitle_1", comment: ""), type: .slide(data: Slide(text: NSLocalizedString("slideText_1", comment: ""), image: "slide-2"))),
            WelcomeSlides(title: NSLocalizedString("slideTitle_2", comment: ""), type: .slide(data: Slide(text: NSLocalizedString("slideText_2", comment: ""), image: "slide-3")))
        ]
        
        self.slidesSubject.onNext(slides)
        
    }
    
}
