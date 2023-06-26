//
//  BaseCoordinator.swift
//  Webasyst X
//
//  Created by Леонид Лукашевич on 25.06.2023.
//

import UIKit

protocol BaseCoordinator: AnyObject {
    var presenter: UINavigationController { get set }
    var screens: ScreensBuilder { get set }
}

extension BaseCoordinator {
    
    func openSettingsList(closure: @escaping () -> ()) {
        let settingListCoordinator = SettingsListCoordinator(presenter: presenter,
                                                             screens: screens,
                                                             block: closure)
        settingListCoordinator.start()
    }
}
