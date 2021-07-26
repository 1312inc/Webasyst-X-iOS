//
//  InstructionWaid module - InstructionWaidViewModel.swift
//  Teamwork
//
//  Created by viktkobst on 22/07/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//MARK: InstructionWaidViewModel
protocol InstructionWaidViewModelType {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output { get }
}

//MARK: InstructionWaidViewModel
final class InstructionWaidViewModel: InstructionWaidViewModelType {

    struct Input {
       //...
    }
    
    let input: Input
    
    struct Output {
       //...
    }
    
    let output: Output
    
    private var disposeBag = DisposeBag()
            
    //MARK: Input Objects
    
    //MARK: Output Objects

    init() {
        //Init input property
        self.input = Input(
            //...
        )

        //Init output property
        self.output = Output(
            //...
        )
    }
    
}
