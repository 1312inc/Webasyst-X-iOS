//
//  PayWallModel.swift
//  Shop-Script
//
//  Created by Леонид Лукашевич on 19.12.2022.
//

import Foundation
import RxSwift
import RxCocoa

//MARK: PayWallModelType
protocol PayWallModelType {
    
}

//MARK: PayWallModel
// If the model is to be passive this class can be deleted
final class PayWallModel: PayWallModelType {
    
}

public enum Plan: String {
    case dreamteam = "X-1312-TEAMWORK-1"
    case dreamteamplus = "X-1312-TEAMWORK-2"
    case none = ""
}
