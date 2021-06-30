//
//  MainTabBar module - MainTabBarViewModel.swift
//  Webasyst-X-iOS
//
//  Created by viktkobst on 30/06/2021.
//  Copyright © 2021 1312 Inc.. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//MARK: ViewModel input properties
protocol MainTabBarViewModelInput {
    //ViewModel inputs properties
}

//MARK: ViewModel output properties
protocol MainTabBarViewModelOutput {
    //ViewModel output properties
}

//MARK: MainTabBarViewModelType
protocol MainTabBarViewModelType {
    var input: MainTabBarViewModelInput { get }
    var output: MainTabBarViewModelOutput { get }
}

//MARK: MainTabBarViewModel
final class MainTabBarViewModel: MainTabBarViewModelInput, MainTabBarViewModelOutput, MainTabBarViewModelType {
    
    var model: MainTabBarModelType
    var input: MainTabBarViewModelInput { return self }
    var output: MainTabBarViewModelOutput { return self }
    
    init(model: MainTabBarModelType) {
        self.model = model
    }
    
}
