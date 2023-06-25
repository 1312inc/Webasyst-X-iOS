//
//  Delegate.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 05.10.2022.
//

import Foundation
import UIKit

protocol PassImageToPreviousController: AnyObject {
    func update(_ image: UIImage?)
}
