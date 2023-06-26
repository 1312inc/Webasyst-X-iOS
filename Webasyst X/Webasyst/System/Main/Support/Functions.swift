//
//  Functions.swift
//  PasscodeLock
//
//  Created by Yanko Dimitrov on 8/28/15.
//  Copyright © 2015 Yanko Dimitrov. All rights reserved.
//

import Foundation

func localizedStringFor(key: String, comment: String? = nil) -> String {
    
    return .getLocalizedString(withKey: key, comment: comment)
}

func bundleForResource(name: String, ofType type: String) -> Bundle {
    
    if (Bundle.main.path(forResource: name, ofType: type) != nil) {
        return Bundle.main
    }
    
    return Bundle(for: PasscodeLock.self)
}

func debug(file: String = #file, line: Int = #line, function: String = #function) -> String {
    let filename = file.components(separatedBy: "/").last ?? ""
    return "\(filename):\(line):\(function)"
}
